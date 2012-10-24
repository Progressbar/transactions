# encoding: utf-8

require 'spec_helper'

describe TransactionProcessor do

  before(:each) do
    @config = Transactions.config
    @maildir = Maildir.new(@config['mailman']['maildir'])
    @maildir.serializer = Maildir::Serializer::Mail.new

    @from_account = 'automat@fio.cz'
    @to_account = 'keraml@gmail.com'
    @valid_income_subject = 'Fio banka - prijem na konte'
    @valid_outcome_subject = 'Fio banka - prijem na konte'

    body = income_message_body('2600121198', '520700-4200304883/8360', '20,00')
    mail = send_test_mail({ from: @from_account, to: @to_account, subject: @valid_income_subject, body: body, charset: 'utf-8' })

    data1 = FioBankMail.new(mail).process(:default).data
    data2 = FioBankMail.new(mail).process(:default).data

    data2[:from_account] = nil
    @valid_transaction = Transaction.new(data1)
    @invalid_transaction = Transaction.new(data2)

    conn = ::Transactions.connection
    logg = ::Transactions.logger
    @transaction_processor = TransactionProcessor.new conn, logg
  end

  describe 'transaction process' do
    it 'should return true' do
      stub_request(:post, "http://localhost:3000/api/transaction/new").to_return(:status => 200, :body => '{"status":true}', :headers => {})
      result = @transaction_processor.process @valid_transaction
      result.should == true
    end

    it 'should return false when server is unavailabile' do
      stub_request(:post, "http://localhost:3000/api/transaction/new").to_return(:status => 500, :body => "Some Error")

      result = @transaction_processor.process @valid_transaction
      result.should == false
    end

    it 'should return false when server return false status' do
      stub_request(:post, "http://localhost:3000/api/transaction/new").to_return(:status => 200, :body => '{"status":false}', :headers => {})
      result = @transaction_processor.process @invalid_transaction
      result.should == false
    end

    # todo test logging
  end
end