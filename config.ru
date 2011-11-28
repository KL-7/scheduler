require 'rubygems'
require 'bundler'
Bundler.require

require './scheduler/app'

run Scheduler::App.new