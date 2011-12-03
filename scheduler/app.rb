module Scheduler

  class App < Sinatra::Base

    use SassHandler
    use CoffeeHandler

    helpers Helpers

    set :app_file, __FILE__
    set :static, true

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