class Order < ActiveRecord::Base
  belongs_to :account
  belongs_to :goal

  TYPES = ["bond bid", "bond ask",
           "swap bid", "swap ask"]

  before_save :execute

  def find_matching_ask
    Order.where(:type_of => "bond ask", :goal_id => self.goal_id, :status => "pending").first
  end

  def find_matching_bid
    Order.where(:type_of => "bond bid", :goal_id => self.goal_id, :status => "pending").first
  end

  def execute
    unless status == "executed"
      self.status = "pending"
      if type_of == "bond bid"
        match = find_matching_ask
        unless match.nil?
          match.account.sell_bond!(self.account)
          self.status = match.status = "executed"
          match.save!
        end
        
      elsif type_of == "bond ask"
        match = find_matching_bid
        unless match.nil?
          account.sell_bond!(match.account)
          self.status = match.status = "executed"
          match.save!
        end
      elsif type_of == "swap bid"
        
      elsif type_of == "swap ask"
        
      end
    end
  end
end
