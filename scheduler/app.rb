module Scheduler

  class App < Sinatra::Base

    include Scheduler::Models

    use SassHandler
    use CoffeeHandler
    helpers Helpers


    #### routes ####


    get '/' do
      login!
      show :root
    end
    
    get '/a/users' do
      @users = Scheduler::DAO.all :users
      show :'a/users'
    end

    post '/a/users' do
      user = User.new params['name'], params['password'], params['role'].to_sym
      Scheduler::DAO.insert :users, user
      redirect '/a/users'
    end
    
    before '/a/*' do
      login! :admin
    end

    get '/login' do
      redirect '/' if current_user
      show :login
    end

    post '/login' do
      user = User.authenticate(params['username'], params['password'])
      if user
        session['user_id'] = user.id
        redirect '/'
      else
        flash[:error] = 'Wrong email or password.'
        show :login
      end
    end

    get '/logout' do
      session.delete 'user_id'
      redirect '/login'
    end


    #### configs ####


    enable :sessions
    set    :session_secret, 'O7PNBfQSNVLYETYdHvO4RqIrn8scsl'

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

  end

end
