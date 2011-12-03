require 'digest/sha2'

module Scheduler
  module Models
    class User

      attr_accessor :name, :hashed_password, :salt, :id

      def initialize(name = nil, password = nil)
        self.name = name if name
        self.password = password
      end

      def password=(pass)
        return unless pass

        self.salt = User::random_string(10) unless self.salt
        self.hashed_password = User.encrypt(pass, self.salt)
      end

      def valid_password?(pass)
        User.encrypt(pass, salt) == hashed_password
      end

      class << self

        def authenticate(name, pass)
          user = DAO.find(:users, name: name)
          user if user && user.valid_password?(pass)
        end

        def encrypt(pass, salt)
          Digest::SHA2.hexdigest(pass + salt)
        end

        def random_string(len)
          chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
          (1..len).map{ chars[rand(chars.size - 1)] }.join
        end

        def from_hash(attrs = {})
          new.tap do |u|
            [:name, :hashed_password, :salt].each { |attr| u.send("#{attr}=", attrs[attr.to_s]) }
            u.id = attrs['_id'].to_s
          end
        end

      end

      def to_hash
        { name: name, hashed_password: hashed_password, salt: salt }.tap do |h|
          h.merge!(:_id => BSON::ObjectId.new(id)) if id
        end
      end

    end
  end
end