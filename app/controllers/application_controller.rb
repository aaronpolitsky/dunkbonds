class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_cart
  def current_cart
  	current_user.cart
  end

end
