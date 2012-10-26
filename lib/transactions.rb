
module Transactions
  ABS_PATH = File.expand_path('../../', __FILE__)

  require "#{ABS_PATH}/lib/transaction.rb"
  require "#{ABS_PATH}/lib/transaction_processor.rb"
  require "#{ABS_PATH}/lib/incoming_mail.rb"
  require "#{ABS_PATH}/lib/fio_bank_mail.rb"

  def self.load_config
    config_yaml = YAML::load(File.read("#{ABS_PATH}/config/config.yml"))
    Hashie::Mash.new(config_yaml[ENV['RAILS_ENV']])
  end

 	def self.config
 		@config ||= load_config
 	end

 	def self.connection
 		# For Fedora and CentOS, use the path and file /etc/pki/tls/certs/ca-bundle.crt instead, or find your system path with openssl version -a.
 		# :ssl => { :ca_file => '/usr/lib/ssl/certs/ca-certificates.crt'}
 		cfg = {
 			url: @config.api_server_url,
 			ssl: { :ca_path => '/usr/lib/ssl/certs' }
 		}

 		@connection ||= Faraday.new(cfg) do |f| # , proxy: 'http://127.0.0.1:3128'
 		    f.request  :url_encoded             # form-encode POST params
 		    # f.response :logger                # log requests to STDOUT
 		    f.adapter  Faraday.default_adapter  # make requests with Net::HTTP
 		    f.headers = {
 		      'Cookie' => '',
 		      'User-Agent' => ''
 		    }
 		end

 	  	@connection
 	end

 	def self.processor
 		@processor = TransactionProcessor.new connection, logger
 	end

 	def self.logger
 		@logger ||= Logger.new(config.logger.use_log_file ? "#{ABS_PATH}/#{config.logger.log_file}" : STDOUT)
 	end

 	def self.generate_digest(data)
 		data = ::Base64.strict_encode64(data.to_s)
 		OpenSSL::HMAC.hexdigest(OpenSSL::Digest.const_get('SHA1').new, config.api_server_secret_token, data)
 	end

 	def self.run_mailman

    fio_bank = config.fio_bank_email
    trans_proc = processor

    Mailman.config.ignore_stdin = config.mailman.ignore_stdin || false
    Mailman.config.logger = logger
    Mailman.config.poll_interval = config.mailman.poll_interval || 60

  	if config.mailman.pop3
  		Mailman.config.pop3 = {
  		  :username => config.mailman.pop3.username,
  		  :password => config.mailman.pop3.password,
  		  :server   => config.mailman.pop3.server,
  		  :port     => config.mailman.pop3.port,
  		  :ssl      => config.mailman.pop3.ssl
  		}
  	else
  		Mailman.config.maildir = "#{ABS_PATH}/#{config.mailman.maildir || 'tmp/test_maildir'}"
  	end

    Mailman::Application.run do
      from(fio_bank) do
        data = FioBankMail.new(message, params).process(:default).data
        trans_proc.process Transaction.new(data)
      end

      default do
        # do nothing for now
        # Mailman.logger.info "unknown sender: #{message.from} - #{message.subject}"
      end
    end

 	end
 end