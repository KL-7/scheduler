$:.unshift File.expand_path(File.dirname(__FILE__))
require 'helpers'
require 'models/user'

module Scheduler

  BASE_DIR_NAME = File.dirname(__FILE__)

  def self.expand_path(path)
    File.join(BASE_DIR_NAME, path)
  end

  class SassHandler < Sinatra::Base
    set :views, Scheduler.expand_path('views/sass')
    get '/css/*.css'do sass params[:splat].first.to_sym end
  end

  class CoffeeHandler < Sinatra::Base
    set :views, Scheduler.expand_path('views/coffee')
    get "/js/*.js" do coffee params[:splat].first.to_sym end
  end

  class App < Sinatra::Base

    use SassHandler
    use CoffeeHandler

    helpers Helpers

    set :app_file, __FILE__
    set :static, true
    set :public_folder, Scheduler.expand_path('public')

    enable :session

    get '/' do
      if @user = session[:user]
        'Only chosen ones see that...'
      else
        redirect '/login'
      end
    end

    get '/login' do
      show :login
    end

    post '/login' do
      if session[:user] = Models::User.authenticate(params['username'], params['password'])
        redirect '/'
      else
        redirect '/login'
      end
    end

  end

end