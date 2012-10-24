# encoding: utf-8
require 'active_support/base64'

class IncomingMail
  def initialize(message, params={})
    @message = message
    @params = params
  end

  def process(method)
    self.send method
    rescue Exception => e
      msg = "Exception occurred while processing message:\n#{@message}"
      msg += "\n#{'-'*80}\n"
      Mailman.logger.error msg
      if ENV['RAILS_ENV'] == 'developmenet'
        Mailman.logger.error [e, *e.backtrace].join("\n") if ENV['RAILS_ENV'] == 'development'
      else
        msg += "Exception message: #{e.message}"
      end

      Mailman.logger.error msg

      raise Exception, "Unable Process Message: #{e.message}"
  end

  def default
  end
end