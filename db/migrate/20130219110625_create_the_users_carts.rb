class CreateTheUsersCarts < ActiveRecord::Migration
  def up
		User.all.each do |u|
			User.create_cart! if User.cart.nil?
		end  	
  end

  def down
  end
end
