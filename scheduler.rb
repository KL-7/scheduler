$:.unshift File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
Bundler.require

require 'lib/mongo_dao'
require 'lib/mongo_fields'
require 'scheduler/helpers'
require 'scheduler/assets_handlers'
require 'scheduler/models/user'
require 'scheduler/models/subject'
require 'scheduler/app'

module Scheduler

  class << self

    private

    def database
      @database ||= init_database
    end

    def init_database
      if Sinatra::Application.production?
        mongo_uri = URI.parse(ENV['MONGOHQ_URL'])
        db_name = mongo_uri.path.gsub(/^\//, '')
        Mongo::Connection.from_uri(mongo_uri.to_s)[db_name]
      else
        Mongo::Connection.new.db("scheduler-#{App.environment}")
      end
    end

  end

  DAO = MongoDAO.new(database, Models)

end
