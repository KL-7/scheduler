module Scheduler

  class App < Sinatra::Base

    include Scheduler::Models

    use SassHandler
    use CoffeeHandler

    helpers Helpers

    set :app_file, __FILE__
    set :static, true

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
      binding.pry
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

  end

end