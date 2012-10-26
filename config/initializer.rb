require 'rubygems'
require 'bundler/setup'
require 'mailman'
require 'yaml'
require 'faraday'
require 'multi_json'
require 'hashie'
require 'openssl' unless defined?(OpenSSL)

require File.expand_path('../../lib/transactions.rb', __FILE__)
