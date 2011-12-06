require 'digest/sha2'

module Scheduler
  module Models
    class Subject

      include MongoFields

      fields :name

      def initialize(name = nil)
        self.name = name
      end

    end
  end
end
