module Scheduler
  module Models
    class Course

      include MongoFields

      fields :name, :lecturer_id, :subject_id, :students_count

      attr_accessor :lecturer, :subject

      MIN_STUDENTS_LIMIT = 10
      MAX_STUDENTS_LIMIT = 20

      def initialize(lecturer_id = nil, subject_id = nil, name = nil)
        self.lecturer_id = lecturer_id
        self.subject_id = subject_id
        self.name = name
        self.students_count = 0
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
        ).sort_by(&:name)
      end

      class << self

        def available_courses
          DAO.all :courses, students_count: { '$lt' => MAX_STUDENTS_LIMIT }
        end

        def add_student(course_id, course_type)
          if !Schedule.valid_course_type?(course_type)
            false
          elsif course_type != :primary
            true
          else # course_type == :primary
            DAO.collection(:courses).update(
               { _id: BSON::ObjectId(course_id),
                 students_count: { '$lt' => MAX_STUDENTS_LIMIT }
               },
               { '$inc' => { students_count: 1 } },
               safe: true
            )['updatedExisting']
          end
        end

        def remove_student(course_id, course_type)
          if !Schedule.valid_course_type?(course_type)
            false
          elsif course_type != :primary
            true
          else
            DAO.collection(:courses).update(
               { _id: BSON::ObjectId(course_id) },
               { '$inc' => { students_count: -1 } },
               safe: true
            )['updatedExisting']
          end
        end

      end

    end
  end
end
