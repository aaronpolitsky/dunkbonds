module ApplicationHelper
	def current_cart
		current_user.cart
	end

	def line_item_total(line_item)
		if line_item.status == "executed"
			if line_item.type_of	 == "bond bid"  || line_item.type_of == "swap bid" 
				return line_item.buys.inject(0){|sum, e| sum += e.qty*e.price }
			else
				return line_item.sells.inject(0){|sum, e| sum += e.qty*e.price } 
			end
		else 
			return ""
		end
	end
end
