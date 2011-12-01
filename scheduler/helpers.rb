module Scheduler
  module Helpers

    def show(template, options = {}, locals = {})
      mustache template, options, locals
    end

  end
end