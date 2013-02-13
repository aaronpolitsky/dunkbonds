module ApplicationHelper

	def within_a_goal?
		(params[:controller].include? 'goal') && !(current_page?(root_path)) && !(current_page?(goals_path)) || 
		(params[:controller].include? 'accounts') && !current_page?(accounts_path) || 
		(params[:controller].include? 'posts') || 		
		(params[:controller]=='line_items')
	end

	def logo
    logo = image_tag("logo.png", :alt => "DUNKbonds", :class => "round")
  end

  def negate_currency(value)
  	unless value == 0 
  		number_to_currency(-value)
  	else 
  		"$0.00"
  	end
  end

  #tab styling
  def selected?(page)
  	if current_page?(page)
  		"selected"
  	else
	  	""
	  end
  end

	# Return a title on a per-page basis.
  def title
    base_title = "DUNKbonds"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

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
