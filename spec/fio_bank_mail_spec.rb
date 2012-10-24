# encoding: utf-8

require 'spec_helper'

describe FioBankMail do

  before(:each) do
    @config = Transactions.config

    @maildir = Maildir.new(@config['mailman']['maildir'])
    @maildir.serializer = Maildir::Serializer::Mail.new

    @from_account = 'automat@fio.cz'
    @to_account = 'keraml@gmail.com'
    @valid_income_subject = 'Fio banka - prijem na konte'
    @valid_outcome_subject = 'Fio banka - prijem na konte'
    @invalid_subject = 'Fio banka - spam'
  end

  describe "for income payment" do

# Příjem na kontě: 2600121198
# Částka: 20,00
# VS:
# Zpráva příjemci: PROGRESSBAR
# Aktuální zůstatek: 1 703,36
# Protiúčet: 520700-4200304883/8360
# SS:
# KS:

    it "should parse and return valid data" do
      body = income_message_body('2600121198', '520700-4200304883/8360', '20,00')
      mail = send_test_mail({ from: @from_account, to: @to_account, subject: @valid_income_subject, body: body, charset: 'utf-8' })
      data = FioBankMail.new(mail).process(:default).data

      data[:to_account].should == '2600121198'
      data[:from_account].should == '520700-4200304883/8360'
      data[:amount].should == '20,00'
      data[:message].should == nil
      data[:vs].should == nil
    end

    it "should raise exception when unknown email type try parse" do
      body = income_message_body('2600121198', '520700-4200304883/8360', '20,00')
      mail = send_test_mail({ from: @from_account, to: @to_account, subject: @invalid_outcome_subject, body: body, charset: 'utf-8' })

      expect{ FioBankMail.new(mail).process(:default) }.to raise_exception
    end

    it "should raise exception when from_account missing in message" do
      body = income_message_body('2600121198', '', '20,00')
      mail = send_test_mail({ from: @from_account, to: @to_account, subject: @valid_income_subject, body: body, charset: 'utf-8' })
      expect{ FioBankMail.new(mail).process(:default) }.to raise_exception
    end
  end

end
