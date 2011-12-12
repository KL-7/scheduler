module Scheduler
  module Models
    class Course

      include MongoFields

      fields :name, :lecturer_id, :subject_id

      attr_accessor :lecturer, :subject

      def initialize(lecturer_id = nil, subject_id = nil, name = nil)
        self.lecturer_id = lecturer_id
        self.subject_id = subject_id
        self.name = name
      end

    end
  end
end
