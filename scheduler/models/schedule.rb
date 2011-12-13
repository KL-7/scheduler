require 'digest/sha2'

module Scheduler
  module Models
    class Schedule

      include MongoFields

      fields :items, :student_id

      COURSE_TYPES = [:primary, :alternative]

      def initialize(student_id = nil, items = [])
        self.student_id = student_id
        self.items = items
      end
      
      def add_course(course_id, course_type)
        if COURSE_TYPES.include?(course_type) && !include_course?(course_id)
          items << { 'course_id' => course_id, 'course_type' => course_type }
          true
        else
          false
        end
      end

      def delete_course(course_id)
        items.delete_if { |item| item['course_id'] == course_id } 
      end

      def include_course?(course_id)
        !!items.detect { |item| item['course_id'] == course_id } 
      end

      def load_courses
        ids = items.map{ |item| item['course_id'] }.compact.uniq    
        courses = DAO.find_by_id(:courses, ids).each_with_object({}) { |p, memo| memo[p.id] = p }
        items.each { |item| item['course'] = courses[item['course_id']] }
      end

    end
  end
end
