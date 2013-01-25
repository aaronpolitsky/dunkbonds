Factory.define :line_item do |li|
  li.qty 1
  li.max_bid_min_ask 10
#  li.account Factory.create(:account)
end

Factory.define :bond_ask, :class => LineItem do |li|
  li.max_bid_min_ask 10
  li.type_of "bond ask"
  li.qty 1
#  li.account Factory.create(:account)
end

Factory.define :bond_bid, :class => LineItem do |li|
  li.max_bid_min_ask 10
  li.type_of "bond bid"
  li.qty 1
#  li.account Factory.create(:account)
end


Factory.define :swap_ask, :class => LineItem do |li|
  li.max_bid_min_ask 10
  li.type_of "swap ask"
  li.qty 1
#  li.account Factory.create(:account)
end

Factory.define :swap_bid, :class => LineItem do |li|
  li.max_bid_min_ask 10
  li.type_of "swap bid"
  li.qty 1
#  li.account Factory.create(:account)
end