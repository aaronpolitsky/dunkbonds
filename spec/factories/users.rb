Factory.define :user do |u|
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  u.email "user@example.com"
  u.password "asdfasdf"
  u.password_confirmation "asdfasdf"
end
