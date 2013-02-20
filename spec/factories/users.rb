Factory.define :user do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "user@example.org"
  u.password "asdfasdf"
  u.name "Bob Loblaw"
  u.password_confirmation "asdfasdf"
end

Factory.define :aaron, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "aaron.politsky@gmail.com"
  u.password "asdfasdf"
  u.name "Aaron Politsky"  
  u.password_confirmation "asdfasdf"
end

Factory.define :dad, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "dad@dad.dad"
  u.password "asdfasdf"
  u.name "David Politsky"  
  u.password_confirmation "asdfasdf"
end

Factory.define :mateo, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "mateo@mateo.mateo"
  u.password "asdfasdf"
  u.name "Mateo Rando"  
  u.password_confirmation "asdfasdf"
end


