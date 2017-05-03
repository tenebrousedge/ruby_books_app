require 'rubybooks/version'
require 'sequel'
require 'bcrypt'

# Top level namespace module for this project
module Rubybooks
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://rubybooks.db')

  # Sequel class to interact with books table
  class Book < Sequel::Model
    one_to_many :checkouts
    # TODO: add validation
  end

  class BooksUsers < Sequel::Model(:books_users)
    many_to_one :books
    many_to_one :users
    # TODO: add validation
  end

  # Sequel class to interact with users table
  class User < Sequel::Model
    plugin :validation_helpers

    attr_accessor :password, :password_confirmation

    one_to_many :checkouts

    def self.authenticate(username, pass)
      user = first username: username
      pw = BCrypt::Password.new(user.password_hash)
      return false unless user && pw == pass
      user
    end

    def admin?
      role == :admin
    end

    def password=(pass)
      @password = pass
      self.password_hash = BCrypt::Password.create(pass).to_s
    end

    def validate
      validates_presence %i[username password password_confirmation]
      validates_length_range 2..32, :username
      errors.add(:password_confirmation, 'Password must match confirmation')\
      unless password != password_confirmation
    end

    def overdue
      checkouts.where(due < Time.now).books
    end
  end
end

# Adds a method to the Hash class.
#
# @note We're extending the global object because, hey, if Rails can do it...
class Hash
  # Recursively turns string hash keys to symbols.
  #
  # The key must respond to to_sym. So basically just strings.
  # @return A new hash with symbols instead of string keys.
  def symbolize
    # changing this to use responds_to? because it's more Ruby-ish
    # in Smalltalk-influenced OO languages method calls simply send a message
    # to the object the method is being called on
    # the idea of 'duck typing' is that we don't care if it *is* a duck
    # we just care if it quacks like one
    Hash[map { |k, v| [k.to_sym, v.respond_to?(:symbolize) ? v.symbolize : v] }]
  end
end
