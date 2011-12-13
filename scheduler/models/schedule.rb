module Scheduler
  module Models

    class ScheduleItem < Struct.new(:course_id, :course_type, :course); end

    class Schedule

      include MongoFields

      fields :items_list, :student_id

      COURSE_TYPES = [:primary, :alternative]

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
        if index = items_list.index { |c| c['course_id'] == course_id }
          items_list.delete_at index
          true
        else
          false
        end
      end

      def include_course?(course_id)
        !!items_list.detect { |c| c['course_id'] == course_id }
      end

      def items
        @items || items!
      end

      def items!
        schedule_items = items_list.map { |c| ScheduleItem.new(c['course_id'], c['course_type']) }
        @items = DAO.load_one_to_one_association(schedule_items, :course)
      end

    end
  end
end