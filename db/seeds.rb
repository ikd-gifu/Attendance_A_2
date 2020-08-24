# coding: utf-8

User.create!(name: "Sample User",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)
             
User.create!(name: "上長_1",
             email: "superior_1@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)

User.create!(name: "上長_2",
             email: "superior_2@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)

puts "Admini & Superior Users Created"

6.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end

puts "General Users Created"