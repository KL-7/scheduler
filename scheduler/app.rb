module Scheduler

  class App < Sinatra::Base

    #### configs ####

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    enable :sessions
    set    :session_secret, 'O7PNBfQSNVLYETYdHvO4RqIrn8scsl'
    set    :method_override, true


    #### includes ####

    include Scheduler::Models

    use Rack::Flash, :sweep => true
    use SassHandler
    use CoffeeHandler
    helpers Helpers


    #### routes ####

    get '/' do
      login!
      show :root
    end
    
    before '/a/*' do
      login! :admin
    end

    get '/a/subjects' do
      @subjects = Scheduler::DAO.all :subjects
      show :'a/subjects'
    end

    post '/a/subject' do
      subject = Subject.new params['name']
      Scheduler::DAO.insert :subjects, subject
      redirect '/a/subjects'
    end

    get '/a/users' do
      @users = Scheduler::DAO.all :users
      show :'a/users'
    end

    post '/a/user' do
      unless params['name'].empty? || params['password'].empty? || DAO.find(:users, name: name)
        user = User.new params['name'], params['password'], params['role'].to_sym
        Scheduler::DAO.insert :users, user
      else
        flash[:alert] = "Name and password can't be blank. Name should be unique."
      end
      redirect '/a/users'
    end

    delete '/a/user/:id' do
      Scheduler::DAO.delete :users, params[:id]
    end

    post '/a/user/:id/reset-password' do
      u = Scheduler::DAO.find_by_id :users, params['id']
      u.reset_password
      Scheduler::DAO.update :users, u
    end

    get '/login' do
      redirect '/' if current_user
      show :login, layout: false
    end

    post '/login' do
      user = User.authenticate(params['username'], params['password'])
      if user
        session['user_id'] = user.id
        redirect '/'
      else
        flash.now[:alert] = 'Wrong username or password.'
        show :login, layout: false
      end
    end

    get '/logout' do
      session.delete 'user_id'
      redirect '/login'
    end

  end

end
