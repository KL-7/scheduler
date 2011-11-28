require 'mustache/sinatra'

$:.unshift File.expand_path(File.dirname(__FILE__))
require 'helpers'
require 'views/layout'

module Scheduler

  class App < Sinatra::Base

    register Mustache::Sinatra
    helpers Helpers

    set :root, File.dirname(__FILE__) + '/..'
    set :app_file, __FILE__

    dir = File.dirname(File.dirname(__FILE__) + "/..")
    set :mustache, { namespace: Scheduler, views: "#{dir}/views/", templates: "#{dir}/templates/" }

    get '/' do
      show :login
    end

  end

end