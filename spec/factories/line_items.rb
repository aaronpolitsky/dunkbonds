Factory.define :line_item do |li|

end

Factory.define :ask, :class => LineItem do |li|
  li.max_bid_min_ask 10
  li.status "pending"
  li.type_of "bond ask"
end

Factory.define :bid, :class => LineItem do |li|
  li.max_bid_min_ask 10
  li.status "pending"
  li.type_of "bond bid"
end
