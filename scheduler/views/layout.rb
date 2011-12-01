module Scheduler
  module Views
    class Layout < Mustache

      def title
        @title || 'Scheduler'
      end

    end
  end
end