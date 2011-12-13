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
      login! nil, false
      show :root
    end

    #### admin pages ####

    before '/a/*' do
      login! :admin
    end

    get '/a/subjects' do
      @subjects = DAO.all :subjects
      show :'a/subjects'
    end

    post '/a/subject' do
      unless params['name'].empty? || DAO.find(:subjects, name: params['name'])
        subject = Subject.new params['name']
        DAO.insert :subjects, subject
        redirect '/a/subjects'
      else
        flash.now[:error] = "Name can't be blank. Name should be unique."
        @subjects = DAO.all :subjects
        show :'a/subjects', nav_path: '/a/subjects'
      end
    end

    delete '/a/subject/:id' do
      DAO.delete_by_id :subjects, params[:id]
    end

    post '/a/users' do
      name     = params['name'] || ''
      password = params['password'] || ''
      role     = params['role'] && params['role'].to_sym

      unless role.nil? || name.empty? || password.size < User::MINIMUM_PASSWORD_LENGTH || DAO.find(:users, name: name)
        user = User.new name, password, role
        DAO.insert :users, user
        DAO.insert :schedules, Schedule.new(user.id)
        redirect '/a/users'
      else
        flash.now[:error] = "Name should be unique. Password should be at least #{User::MINIMUM_PASSWORD_LENGTH} characters long."
        @users = DAO.all :users
        show :'a/users'
      end
    end

    get '/a/users' do
      @users = DAO.all :users
      show :'a/users'
    end

    delete '/a/user/:id' do
      DAO.delete_by_id :users, params[:id]
      DAO.delete :schedules, { student_id: params[:id] }
    end

    post '/a/user/:id/reset-password' do
      u = DAO.find_by_id :users, params['id']
      new_password = u.reset_password
      DAO.update :users, u

      content_type :json
      { password: new_password, username: u.name }.to_json
    end

    #### lecturer pages ####

    before '/l/*' do
      login! :lecturer
    end

    get '/l/courses' do
      @subjects = DAO.all :subjects
      @courses = DAO.load_one_to_one_association(DAO.all(:courses), :subject)
      show :'l/courses'
    end

    post '/l/courses' do
      name = params['name'] || ''
      subject = DAO.find_by_id :subjects, params['subject_id']

      unless name.empty? || subject.nil? || DAO.find(:courses, lecturer_id: current_user.id, name: name)
        course = Course.new current_user.id, subject.id, name
        DAO.insert :courses, course
        redirect '/l/courses'
      else
        flash.now[:error] = "Name should be unique for current lecturer."
        @subjects = DAO.all :subjects
        @courses = DAO.load_one_to_one_association(DAO.all(:courses), :subject)
        show :'l/courses'
      end
    end

    delete '/l/course/:id' do
      DAO.delete_by_id :courses, params[:id]
    end

    #### students pages ####

    before '/s/*' do
      login! :student
    end

    get '/s/schedule' do
      @courses = DAO.all(:courses)
      @schedule = DAO.find(:schedules, { student_id: current_user.id }) || Schedule.new(current_user.id)
      show :'/s/schedule'
    end

    post '/s/schedule' do
      @schedule = DAO.find(:schedules, { student_id: current_user.id }) || Schedule.new(current_user.id)
      if @schedule.add_course(params['course_id'], params['course_type'].to_sym)
        DAO.save :schedules, @schedule
        redirect '/s/schedule'
      else
        @courses = DAO.all(:courses)
        flash.now[:error] = 'Failed to add course to schedule.'
        show :'/s/schedule'
      end
    end

    delete '/s/schedule/:id' do
      if @schedule = DAO.find(:schedules, { student_id: current_user.id })
        @schedule.remove_course(params['id'])
        DAO.update :schedules, @schedule
      end
    end

    #### profile pages ####

    get '/profile' do
      login!
      show :profile
    end

    post '/profile' do
      login!

      current_password = params['current_password'] || ''
      new_password     = params['new_password'] || ''

      if current_user.valid_password?(current_password) && new_password.size >= User::MINIMUM_PASSWORD_LENGTH
        current_user.password = new_password
        DAO.update :users, current_user
        flash.now[:success] = "Your password was successfully updated."
      else
        flash.now[:error] = "Wrong current or new password. Password should be at least #{User::MINIMUM_PASSWORD_LENGTH} characters long."
      end

      show :profile
    end

    #### auth ####

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
        flash.now[:error] = 'Wrong username or password.'
        show :login, layout: false
      end
    end

    get '/logout' do
      session.delete 'user_id'
      redirect '/login'
    end

  end

end
