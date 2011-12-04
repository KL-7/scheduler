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

  class << self

    private

    def database
      @database ||= init_database
    end

    def init_database
      if Sinatra::Application.production?
        Mongo::Connection.from_uri(URI.parse(ENV['MONGOHQ_URL'])).db
      else
        Mongo::Connection.new.db("scheduler-#{App.environment}")
      end
    end

  end

  DAO = MongoDAO.new(database, Models)

end