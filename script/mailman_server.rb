#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= 'development'

require './config/initializer.rb'

if ENV['RAILS_ENV'] == 'development'
	`rm /home/web-data/work/progressbar/cron-scripts/transactions/tmp/test_maildir/cur/*eml*`
	`cp /home/web-data/work/progressbar/cron-scripts/transactions/prijem.eml /home/web-data/work/progressbar/cron-scripts/transactions/tmp/test_maildir/new/prijem.eml`
end

transaction_processor = TransactionProcessor.new Transactions.connection, Transactions.logger

Mailman::Application.run do
  from(Transactions.config['fio_bank_email']) do
    data = FioBankMail.new(message, params).process(:default).data
    transaction_processor.process Transaction.new(data)
  end

  default do
    # IncomingMail.new(message, params).process(:default)
  end
end