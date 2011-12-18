module Scheduler
  module Models

    class ScheduleItem < Struct.new(:course_id, :course_type, :course); end

    class Schedule

      include MongoFields

      fields :items_list, :student_id

      COURSE_TYPES = [:primary, :alternative]

      PRIMARY_COURSES_LIMIT = 4
      ALTERNATIVE_COURSES_LIMIT = 2

      def initialize(student_id = nil)
        self.student_id = student_id
        self.items_list = []
      end
      
      def add_course(course_id, course_type)
        if COURSE_TYPES.include?(course_type) && !include_course?(course_id)
          items_list << { 'course_id' => course_id, 'course_type' => course_type }
          true
        else
          false
        end
      end

      def remove_course(course_id)
        index = items_list.index { |c| c['course_id'] == course_id }
        items_list.delete_at(index) if index
      end

      def include_course?(course_id)
        !!items_list.detect { |c| c['course_id'] == course_id }
      end

      def course_type(course_id)
        items_list.detect{ |c| c['course_id'] == course_id }['course_type']
      end

      def items
        @items || items!
      end

      def items!
        schedule_items = items_list.map { |c| ScheduleItem.new(c['course_id'], c['course_type']) }
        @items = DAO.load_associations(schedule_items, :course)
        DAO.load_associations(@items.map(&:course), lecturer: :users)
      end

    end
  end
end
