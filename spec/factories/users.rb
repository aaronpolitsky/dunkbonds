Factory.define :user do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "user@example.org"
  u.password "asdfasdf"
  u.first_name "Bob"
  u.last_name "Loblaw"
  u.password_confirmation "asdfasdf"
end

Factory.define :aaron, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "aaron.politsky@gmail.com"
  u.password "asdfasdf"
  u.first_name "Aaron"
  u.last_name "Politsky"  
  u.password_confirmation "asdfasdf"
end

Factory.define :dad, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "dad@dad.dad"
  u.password "asdfasdf"
  u.first_name "David"
  u.last_name "Politsky"  
  u.password_confirmation "asdfasdf"
end

Factory.define :mateo, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "mateo@mateo.mateo"
  u.password "asdfasdf"
  u.first_name "Mateo"
  u.last_name "Rando"  
  u.password_confirmation "asdfasdf"
end


