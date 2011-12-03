module Scheduler

  module Helpers

    def show(template, options = {}, locals = {})
      haml template, options, locals
    end

  end

end