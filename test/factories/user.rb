Factory.sequence :name do |n|
  "username#{n}"
end

Factory.sequence :email do |n|
  "email#{n}@example.com"
end

Factory.define :user do |f|
  f.login                 { Factory.next(:name) }
  f.email                 { Factory.next(:email) }
  f.name                  "User Name"
  f.password              "password"
  f.password_confirmation "password"
end