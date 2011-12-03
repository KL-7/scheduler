require 'rubygems'
require 'bundler'
Bundler.require

require './scheduler'

run Scheduler::App.new