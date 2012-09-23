class Order < ActiveRecord::Base
  belongs_to :account
  belongs_to :goal

  TYPES = ["bond bid", "bond ask",
           "swap bid", "swap ask"]

  before_save :execute

  def find_bond_ask
    match = Order.where(:type_of => "bond_ask").first
    

  end

  def execute
    status = "pending"
    if type_of == "bond bid"
      find_bond_ask
    elsif type_of == "bond ask"
      
    elsif type_of == "swap bid"
      
    elsif type_of == "swap ask"

    end
  end
end
