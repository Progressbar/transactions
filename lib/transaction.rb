# encoding: utf-8

class Transaction
  attr_reader :data

  def initialize data
  	@data = data
  	@data[:currency] ||= 'EUR'
  	@data[:realized_at] ||= DateTime.now
  	@data[:stamp] = ::Transactions.generate_digest(@data)
  end

  def stamp
    @data[:stamp]
  end

end