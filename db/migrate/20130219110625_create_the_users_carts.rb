class CreateTheUsersCarts < ActiveRecord::Migration
  def up
		User.all.each do |u|
			u.create_cart! if u.cart.nil?
		end  	
  end

  def down
  end
end
