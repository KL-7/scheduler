module Scheduler
  module Models
    class Course

      include MongoFields

      fields :name, :lecturer_id, :subject_id

      attr_accessor :lecturer, :subject

      MIN_STUDENTS_LIMIT = 10
      MAX_STUDENTS_LIMIT = 20

      def initialize(lecturer_id = nil, subject_id = nil, name = nil)
        self.lecturer_id = lecturer_id
        self.subject_id = subject_id
        self.name = name
      end

      def students
        @students || students!
      end

      def students!
        @students = DAO.find_by_id(
            :users,
            DAO.all(
                :schedules,
                { items_list: { '$elemMatch' => { course_id: id } } },
                fields: [:student_id]
            ).map(&:student_id)
        )
      end

      def status
      end

    end
  end
end
