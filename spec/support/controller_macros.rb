module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in Factory.create(:admin) # Using factory girl as an example
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = Factory.create(:user)
      user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the confirmable module
      sign_in user
    end
  end
end
