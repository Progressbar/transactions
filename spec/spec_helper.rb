# encoding: utf-8

$VERBOSE = ENV['VERBOSE'] || false
ENV['RAILS_ENV'] ||= 'test'

require 'rubygems'
require 'maildir'
require 'rspec'
require 'webmock/rspec'

def setup_environment
  `rm /home/web-data/work/progressbar/cron-scripts/transactions/log/mailman_test.log`

  require File.expand_path("../../config/initializer", __FILE__)

  RSpec.configure do |config|
    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
  end

end

def each_run

#  `rm /home/web-data/work/progressbar/cron-scripts/transactions/tmp/test_maildir/cur/*eml*`
#  `cp /home/web-data/work/progressbar/cron-scripts/transactions/prijem.eml /home/web-data/work/progressbar/cron-scripts/transactions/tmp/test_maildir/new/prijem.eml`

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories including factories.
  # ([Rails.root.to_s]).map{|p|
  #   Dir[File.join(p, 'spec', 'support', '**', '*.rb').to_s]
  # }.flatten.sort.each do |support_file|
  #   require support_file
  # end
end

# If spork is available in the Gemfile it'll be used but we don't force it.
unless (begin; require 'spork'; rescue LoadError; nil end).nil?
  Spork.prefork do
    # Loading more in this block will cause your tests to run faster. However,
    # if you change any configuration or code from libraries loaded here, you'll
    # need to restart spork for it take effect.
    setup_environment
  end

  Spork.each_run do
    # This code will be run each time you run your specs.
    each_run
  end
else
  setup_environment
  each_run
end

def send_test_mail mail
  mail = Mail.new(mail)
  # @sent = @maildir.add(@mail)
  return mail
end

def income_message_body(to_account, from_account, ammount, vs='', message='')
  return "
Příjem na kontě: #{to_account}
Částka: #{ammount}
VS: #{vs}
Zpráva příjemci: #{message}
Aktuální zůstatek: 1 337,00
Protiúčet: #{from_account}
SS:
KS:
"
end