#!/usr/bin/env ruby

require 'rubygems'
require "bundler/setup"
require 'daemons'

Daemons.run(File.join(File.dirname(__FILE__), 'mailman_server.rb'))