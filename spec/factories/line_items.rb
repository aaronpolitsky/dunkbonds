Factory.define :line_item do |li|
  li.qty 1
end

Factory.define :ask, :class => LineItem do |li|
  li.max_bid_min_ask 10
  li.status "pending"
  li.type_of "bond ask"
  li.qty 1
end

Factory.define :bid, :class => LineItem do |li|
  li.max_bid_min_ask 10
  li.status "pending"
  li.type_of "bond bid"
  li.qty 1
end
