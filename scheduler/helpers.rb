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

  end

end
