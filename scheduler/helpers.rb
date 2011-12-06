module Scheduler

  module Helpers

    def show(template, options = {}, locals = {})
      haml template, options, locals
    end

    def login!(role = nil)
      redirect '/login' unless current_user && (role.nil? || current_user.role == role)
    end

    def current_user
      @current_user ||= DAO.find_by_id(:users, session['user_id'])
    end

    def flash
      @flash ||= {}
    end

    def navigation
      @navigation ||= case current_user.role
        when :admin
          [
              { title: 'Home',     path: '/' },
              { title: 'Users',    path: '/a/users' },
              { title: 'Subjects', path: '/a/subjects' }
          ]
        else
          [
              { title: 'Home', path: '/' }
          ]
      end.map do |item|
        item.merge active: item[:path] == request.path_info
      end
    end

  end

end
