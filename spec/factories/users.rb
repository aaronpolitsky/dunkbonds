Factory.define :user do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "user@example.org"
  u.password "asdfasdf"
  u.first_name "User"
  u.last_name "Loser"
  u.password_confirmation "asdfasdf"
end

Factory.define :asdf, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "asdf@asdf.asdf"
  u.password "asdfasdf"
  u.first_name "AS"
  u.last_name "DF"  
  u.password_confirmation "asdfasdf"
end

Factory.define :fdsa, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "fdsa@fdsa.fdsa"
  u.password "fdsafdsa"
  u.first_name "Mr. Bob"
  u.last_name "Dabolina"  
  u.password_confirmation "fdsafdsa"
end


