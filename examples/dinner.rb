require "rubygems"
require "aclatraz"
require "activerecord"

Aclatraz.init :redis, "http://localhost:6739/0"

class Person < ActiveRecord::Base
  include Aclatraz::Suspect
end

class Dinner < ActiveRecord::Base
end

class Kitchen
  include Aclatraz::Guard
  
  suspects "@person" do 
    deny all
    action :eat_dinner do
      allow :hungry
    end
    action :get_dinner do 
      allow :servant_at => Dinner
      allow :creator_of => "@dinner"
    end
    action :prepare_dinner do 
      allow :chef
    end
  end
  
  attr_accessor :person
  
  def initialize(person)
    @person = person
  end
  
  def prepare_dinner
    guard! :lay_dinner
    @dinner = Dinner.create
    @person.is.creator_of!(@dinner)
  end
  
  def get_dinner(id)
    @dinner = Dinner.find(id)
    guard! :get_dinner
  end
  
  def eat_dinner(id)
    @dinner = Dinner.find(id)
    guard! :eat_dinner
    @dinner.destroy
  end
end

# Examples...

person  = Person.find(10)
kitchen = Kitchen.new(person)

kitchen.prepare_dinner                      # => Access denied
person.is.chef!
kitchen.prepare_dinner                      # => Ok

kitchen.get_dinner(10)                      # => Ok, he creates the @dinner
person.is_not.creator_of!(Dinner.find(10))
kitchen.get_dinner(10)                      # => Access denied
person.is.servant_at!(Dinner)
kitchen.get_dinner(10)                      # => Ok

kitchen.eat_dinner(10)                      # => Access denied, he is not hungry!
person.is.hungry!
kitchen.eat_dinner(10)                      # => Ok, enjoy your meal :)
person.is_not.hungry!

