module Scheduler
  module Models

    class ScheduleItem < Struct.new(:course_id, :course_type, :course); end

    class Schedule

      include MongoFields

      fields :items_list, :student_id

      COURSE_TYPES = [:primary, :alternative]

      COURSE_LIMITS = { primary: 4, alternative: 2 }

      def initialize(student_id = nil)
        self.student_id = student_id
        self.items_list = []
      end
      
      def add_course(course_id, course_type)
        return false unless self.class.valid_course_type?(course_type)

        if !include_course?(course_id) && courses_count(course_type) < COURSE_LIMITS[course_type]
          items_list << { 'course_id' => course_id, 'course_type' => course_type }
          return true
        end

        false
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

      def courses_count(course_type = nil)
        if self.class.valid_course_type?(course_type)
          items_list.count { |c| c['course_type'] == course_type }
        else
          items_list.size
        end
      end

      def items(course_type = nil)
        filter_items(@items || items!, course_type)
      end

      def items!(course_type = nil)
        filter_items(init_items, course_type)
      end

      def self.valid_course_type?(course_type)
        COURSE_TYPES.include? course_type
      end

      private

      def init_items
        @items = items_list.map { |c| ScheduleItem.new(c['course_id'], c['course_type']) }
        DAO.load_associations(@items, :course)
        DAO.load_associations(@items.map(&:course), lecturer: :users)
        @items.sort_by! { |i| i.course.name }
      end

      def filter_items(items, course_type)
        self.class.valid_course_type?(course_type) ? items.select { |i| i.course_type == course_type } : items
      end

    end
  end
end
