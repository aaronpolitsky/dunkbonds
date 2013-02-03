Factory.define :user do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "user@example.org"
  u.password "asdfasdf"
  u.password_confirmation "asdfasdf"
end

Factory.define :asdf, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "asdf@asdf.asdf"
  u.password "asdfasdf"
  u.password_confirmation "asdfasdf"
end

Factory.define :fdsa, :class => User do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "fdsa@fdsa.fdsa"
  u.password "fdsafdsa"
  u.password_confirmation "fdsafdsa"
end


