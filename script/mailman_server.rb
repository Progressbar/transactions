#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= 'development'

require File.expand_path('../../config/initializer', __FILE__)

Transactions.run_mailman