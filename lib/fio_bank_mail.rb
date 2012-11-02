# encoding: utf-8

class FioBankMail < IncomingMail

  def default
    @data = parse_body @message.body.to_s.force_encoding('UTF-8')
    @data[:raw] = ::Base64.strict_encode64(@message.to_s)
    @data[:realized_at] = @message.date || DateTime.now

    self
  end

  def data
    @data
  end

  def income?
    @message.subject =~ /prijem/ ? true : false
  end

  def outcome?
    @message.subject =~ /vydej/ ? true : false
  end

  def parse_body body
    if income?
      data = parse_income body
    elsif outcome?
      data = parse_outcome body
    else
      raise Exception, 'Unable parse unknown email (transaction) type'
    end

    data
  end

  def parse_income body
    data = { :primary_type => 'income' }

    to_account_rgxp = body.match '^Příjem na kontě: (.+)$'
    from_account_rgxp = body.match '^Protiúčet: (.+)$'
    amount_rgxp = body.match '^Částka: (.+)$'
    vs_rgxp = body.match '^VS: (.+)$'
    message_rgxp = body.match '^Zpráva příjemci: (.+)$'

    raise Exception, 'income: to account parse error' if to_account_rgxp.nil?
    raise Exception, 'income: from account parse error' if from_account_rgxp.nil?
    raise Exception, 'income: amount parse error' if amount_rgxp.nil?

    data[:to_account] = to_account_rgxp[1].strip
    data[:from_account] = from_account_rgxp[1].strip
    data[:amount] = amount_rgxp[1].strip
    data[:vs] = vs_rgxp[1].strip if vs_rgxp
    data[:message] = message_rgxp[1].strip if message_rgxp

    data
  end

  def parse_outcome body
    data = { :primary_type => 'outcome' }
    to_account_rgxp = body.match '\nVýdaj na kontě: (.+)$'
    from_account_rgxp = body.match '\nProtiúčet: (.+)$'
    amount_rgxp = body.match '\nČástka: (.+)$'
    vs_rgxp = body.match '\nVS: (.+)$'
    message_rgxp ='\nUS: (.*)'

    raise Exception, 'outcome: to account parse error' if to_account_rgxp.nil?
    raise Exception, 'outcome: from account parse error' if from_account_rgxp.nil?
    raise Exception, 'outcome: amount parse error' if amount_rgxp.nil?

    data[:to_account] = to_account_rgxp[1]
    data[:from_account] = from_account_rgxp[1]
    data[:amount] = amount_rgxp[1]
    data[:vs] = vs_rgxp[1] if vs_rgxp
    data[:message] = message_rgxp[1] if message_rgxp

    data
  end
end