# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
@user1 = User.new(
      :username              => "admin", 
      :email                 => "abc@gmail.com",
      :password              => "password",
      :password_confirmation => "password",
      :role                  => "admin" ,
      :first_name            => "Parminder",
      :last_name             => "Singh",
      :mobile                => "9111111111"      
  )
  @user1.save!
  
@user2 = User.new(
      :username              => "employee", 
      :email                 => "xyz@gmail.com",
      :password              => "password",
      :password_confirmation => "password",
      :role                  => "employee" ,
      :first_name            => "Harry ",
      :last_name             => "Potter",
      :mobile                => "9222222222"      
  )
  @user2.save!