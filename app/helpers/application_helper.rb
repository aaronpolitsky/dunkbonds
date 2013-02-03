module ApplicationHelper
	def current_cart
		current_user.cart
	end
end
