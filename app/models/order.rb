class Order < ActiveRecord::Base
  belongs_to :account
  belongs_to :goal

  TYPES = ["bond_sale", "bond_purchase",
           "swap_sale", "swap_purchase"]
end
