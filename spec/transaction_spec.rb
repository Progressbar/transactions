# encoding: utf-8

require 'multi_json'
require 'spec_helper'

describe "Transaction" do

  before(:each) do
    @config = Transactions.config
    @maildir = Maildir.new(@config['mailman']['maildir'])
    @maildir.serializer = Maildir::Serializer::Mail.new

    @from_account = 'automat@fio.cz'
    @to_account = 'keraml@gmail.com'
    @valid_income_subject = 'Fio banka - prijem na konte'
    @valid_outcome_subject = 'Fio banka - prijem na konte'
  end

    it "should have same stamp for equal data" do
        body = income_message_body('2600121198', '520700-4200304883/8360', '20,00')
        mail = send_test_mail({ from: @from_account, to: @to_account, subject: @valid_income_subject, body: body, charset: 'utf-8' })

        data1 = FioBankMail.new(mail).process(:default).data
        data2 = FioBankMail.new(mail).process(:default).data

        transaction1 = Transaction.new(data1)
        transaction2 = Transaction.new(data2)
        transaction1.stamp.should == transaction2.stamp
    end

    it "should have diferent stamp for diferent data" do
        body1 = income_message_body('2600121198', '520700-4200304883/8360', '20,00')
        body2 = income_message_body('2600121198', '520700-4200304883/8360', '20,00', 1337)
        mail1 = send_test_mail({ from: @from_account, to: @to_account, subject: @valid_income_subject, body: body1, charset: 'utf-8' })
        mail2 = send_test_mail({ from: @from_account, to: @to_account, subject: @valid_income_subject, body: body2, charset: 'utf-8' })

        data1 = FioBankMail.new(mail1).process(:default).data
        data2 = FioBankMail.new(mail2).process(:default).data

        transaction1 = Transaction.new(data1)
        transaction2 = Transaction.new(data2)
        transaction1.stamp.should_not == transaction2.stamp
    end

end