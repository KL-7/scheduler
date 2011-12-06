require 'digest/sha2'

module Scheduler
  module Models
    class User

      include MongoFields

      fields :name, :hashed_password, :salt, :role

      ROLES = [:student, :admin, :lecturer]

      DEFAULT_PASSWORD = '111111'

      def initialize(name = nil, password = nil, role = :student)
        self.name = name
        self.password = password
        self.role = ROLES.include?(role) ? role : :student
      end

      def password=(pass)
        return unless pass

        self.salt = User::random_string(10) unless self.salt
        self.hashed_password = User.encrypt(pass, self.salt)
      end

      def valid_password?(pass)
        User.encrypt(pass, salt) == hashed_password
      end

      def reset_password
        self.password = DEFAULT_PASSWORD
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

      end

      def method_missing(*args, &block)
        # for every role defines method to check if the user has this role (e.g. admin? method for :admin role)
        args.first.to_s =~ /^(#{ROLES.join('|')})\?$/ ? role.to_s == $1 : super
      end

    end
  end
end
