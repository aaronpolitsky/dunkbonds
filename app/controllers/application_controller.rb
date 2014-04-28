class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter: log_referrer_request

  helper_method :current_cart
  def current_cart
  	current_or_guest_user.cart
  end


	# if user is logged in, return current_user, else return guest_user
  helper_method :current_or_guest_user  
  def current_or_guest_user  
    if current_user
      if session[:guest_user_id]
        logging_in
        guest_user.destroy
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    if !User.exists?(session[:guest_user_id])
      #clear out stale session guest ids
      session[:guest_user_id] = nil
    end
    User.find(session[:guest_user_id] ||= create_guest_user.id)
  end

  private

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def logging_in
    # For example:
    # guest_comments = guest_user.comments.all
    # guest_comments.each do |comment|
      # comment.user_id = current_user.id
      # comment.save
    # end

    #transfer followed goals
    guest_user.followed_goals.each do |fg|
      current_user.follow_goal(fg)
    end

    #transfer line items to user cart
    cart = guest_user.cart
    cart.line_items.each do |li|
      li.cart = current_user.cart
      li.account = current_user.accounts.find_by_goal_id(li.account.goal)
      li.save!
    end
  end

  def create_guest_user
    u = User.new(:name => "guest", 
                 :email => "guest_#{Time.now.to_i}#{rand(99)}@example.com",
                 :password => "just visiting, thanks.")
    u.is_guest = true
    u.save!
    u
  end

  def log_referrer_request
    logger.info "hi"
  end
  
end
