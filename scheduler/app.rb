module Scheduler

  class App < Sinatra::Base

    include Scheduler::Models

    use SassHandler
    use CoffeeHandler

    helpers Helpers

    enable :sessions
    set    :session_secret, 'O7PNBfQSNVLYETYdHvO4RqIrn8scsl'

    get '/' do
      if @user = DAO.find_by_id(:users, session['user_id'])
        show :root
      else
        redirect '/login'
      end
    end

    get '/login' do
      show :login
    end

    post '/login' do
      user = User.authenticate(params['username'], params['password'])
      if user
        session[:user_id] = user.id
        redirect '/'
      else
        show :login
      end
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

  end

end