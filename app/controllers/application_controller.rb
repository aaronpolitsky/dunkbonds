class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_cart

  private

  def my_current_user
    if User.count.zero?
      u = User.create!(:name => "guest", 
                       :email => "guest_#{Time.now.to_i}#{rand(99)}@example.com",
                       :password => "just visiting, thanks.")
    end
    User.first 
  end

  def current_cart
    Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    cart = Cart.create
    session[:cart_id] = cart.id
    cart
  end


end
