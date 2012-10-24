# encoding: utf-8

class TransactionProcessor

  API_PATHNAME = '/api/transaction/new'

  def initialize api_server_connection, logger
    @connection = api_server_connection
    @logger = logger
  end

  def process transaction
    response = @connection.post API_PATHNAME, {
      :transaction => transaction.data
    }

    raise "Api Server Error: #{response.body}" if response.status != 200

    result = MultiJson.decode(response.body)

    raise 'Server Response Status Error' if result['status'].nil? or result['status'] == false

    true
  rescue
    msg = "Error occurred while processing transaction:\ntransaction: #{transaction.data}\n #{$!.message}"
    msg += " : #{result['errors']}" if result and result['errors']
    msg += "\n#{'-'*80}\n"
    @logger.error msg

    false
  end

end