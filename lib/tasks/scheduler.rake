desc "This is the monthly bond task"

# to be run daily, but checks if it is the beginning of the month
task :daily_bond_task => :environment do 
  today = Date.today
  if (today == today.beginning_of_month)

    puts "1st of month"

    puts "turn on 'maintenance page' on heroku"
    # system "heroku maintenance:on"

    # puts "Closing Market..."
    # close market

    Goal.where(:period => '1 month') do |g| 
      treasury = g.treasury

      puts "Cancelling pending line items..."
      g.line_items.where(:status => "pending") do |li|
        unless li.cart.nil?
          relative = li.child if li.child
          relative = li.parent if li.parent_id
          li.destroy
          relative.destroy if relative
        else #the line_item is already part of an order
          li.cancel! if li.status == "pending"
        end
      end

      puts "Paying Bond Coupons..."
      g.bonds.each do |b|
        b.pay_coupons
      end
      puts "done."

      puts "take off maintenance page"
      system "heroku maintenance:off"
      puts "done."
    end
  else   
    puts "not 1st of month"
  end

end


task :update_feed => :environment do 
  puts "Updating feed...."
  Goal.all.each do |g| 
    g.update_from_feed
  end
end
