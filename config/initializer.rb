require 'rubygems'
require 'bundler/setup'
require 'mailman'
require 'yaml'
require 'faraday'
require 'multi_json'
require './lib/transaction.rb'
require './lib/transaction_processor.rb'
require './lib/incoming_mail.rb'
require './lib/fio_bank_mail.rb'

require 'openssl' unless defined?(OpenSSL)

module Transactions
	ENV['RAILS_ENV'] ||= 'development'
	SECRET_TOKEN = 'test' # config['api_server_secret_token']

	def self.config
		@config ||= load_config
	end

	def self.load_config
		config_yaml = YAML.load_file(File.expand_path("../transactions.yml", __FILE__))
		config_yaml[ENV['RAILS_ENV']]
	end

	def self.connection
		# For Fedora and CentOS, use the path and file /etc/pki/tls/certs/ca-bundle.crt instead, or find your system path with openssl version -a.
		# :ssl => { :ca_file => '/usr/lib/ssl/certs/ca-certificates.crt'}
		cfg = {
			url: @config['api_server_url'],
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

	def self.logger
    	@logger ||= Logger.new File.expand_path("../../#{@config['log_file']}", __FILE__)
	end

	def self.generate_digest(data)
		data = ::Base64.strict_encode64(data.to_s)
		OpenSSL::HMAC.hexdigest(OpenSSL::Digest.const_get('SHA1').new, SECRET_TOKEN, data)
	end

 	Mailman.config.ignore_stdin = config['mailman']['ignore_stdin'] || false
 	Mailman.config.logger = logger
	Mailman.config.maildir = File.expand_path("../../#{@config['mailman']['maildir']}", __FILE__)

end