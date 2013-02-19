class MorphOrdersLineItemsTradesCancellations < ActiveRecord::Migration
	def up
  	#   for each order
		#     add a line item to this order of qty 1 when it was created
		Order.all.each do |o|
			#ignore treasury orders that got cancelled
			unless (o.account_id == 2 && o.status == "cancelled")
				li = LineItem.new(:order_id => o.id,
				                  :created_at => o.created_at,
				                  :type_of => "bond #{o.type_of}",
				                  :max_bid_min_ask => o.type_of == "bid" ? o.max_bid : o.min_ask,
				                  :account_id => o.account_id,
				                  :qty => 1,
				                  :updated_at => o.updated_at)
				li.save!
			end
		end			
		
		LineItem.all.each do |li|
	  	#			if it is cancelled, 
	  	#				add a cancellation at order's updated time
			# 			set line item updated at time to order's updated at time  					
			if li.order.status == "cancelled"
				li.status = "cancelled"
				li.save!
				li.create_cancellation!(:created_at => li.order.updated_at, 
				                        :updated_at => li.order.updated_at)
			elsif li.order.status == "executed"
		  	#     if the line item is not set to executed, add a trade to the line item linking it to the match order line item
		  	#       be sure trades don't pay!
		  	#       record trade price
		  	#     set statuses of each

		  	if li.status != "executed"
		  		li.status = "executed" 
		  		li.save!
		  	end
		  	if li.type_of == "bond bid"
		  		if li.buys.empty?
		  			match = LineItem.where(:order_id => li.order.match_id).first
		  			li.buys.create!(:ask => match, 
		  			                :qty => 1, 
		  			                :price => match.max_bid_min_ask,
		  			                :created_at => li.order.updated_at,
		  			                :updated_at => li.order.updated_at)
		  			match.status = "executed"
		  			match.save!
		  		end
		  	else
		  		if li.sells.empty?
		  			match = LineItem.where(:order_id => li.order.match_id).first
		  			li.sells.create!(:bid => match,
		  			                 :qty => 1,
		  			                 :price => li.max_bid_min_ask,
		  			                 :created_at => li.order.updated_at,
		  			                 :updated_at => li.order.updated_at)
		  			match.status = "executed"
		  			match.save!
		  		end
		  	end
		  end
		end

		change_table :orders do |t|
			remove :account_id, :type_of, :status, :max_bid, :min_ask, :updated_by, :is_deleted, :goal_id, :bond_id, :price, :match_id
		end
	end  	


	def down
		#seriously?
		#restore from backup
	end
end
