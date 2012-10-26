ENV['RAILS_ENV'] ||= 'development'

require 'rake'
require File.expand_path('../config/initializer', __FILE__)

namespace :mailman do
  desc "Mailman::Start"
  task :start do
    Transactions.run_mailman
  end

  desc "Mailman::Stop"
  task :stop do
  end

  desc "Mailman::Restart"
  task :restart => [:stop, :start] do
  end
end