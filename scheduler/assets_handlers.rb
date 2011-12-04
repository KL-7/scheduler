module Scheduler

  VIEWS_DIR = File.join(File.dirname(__FILE__), 'views')

  class SassHandler < Sinatra::Base
    set :views, File.join(VIEWS_DIR, 'sass')
    get '/css/*.css' do sass params[:splat].first.to_sym end
  end

  class CoffeeHandler < Sinatra::Base
    set :views, File.join(VIEWS_DIR, 'coffee')
    get "/js/*.js" do coffee params[:splat].first.to_sym end
  end

end