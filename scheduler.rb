$:.unshift File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
Bundler.require

require 'lib/mongo_dao'
require 'scheduler/helpers'
require 'scheduler/assets_handlers'
require 'scheduler/models/user'
require 'scheduler/app'

module Scheduler

  def self.database
    @database ||= Mongo::Connection.new.db("scheduler-#{App.environment}")
  end
  private_class_method :database

  DAO = MongoDAO.new(database, Models)

end