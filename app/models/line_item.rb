class LineItem < ActiveRecord::Base
  belongs_to :account
  belongs_to :goal
  belongs_to :cart
  belongs_to :order

  TYPES = ["bond bid", "bond ask",
           "swap bid", "swap ask"]

  STATUSES = ["new", 
              "in cart",
              "pending",
              "executed",
              "cancelled"]
  
  after_create :set_new_status

  def set_new_status
    self.status = "new" 
    self.save!
  end

  def find_matching_ask
    LineItem.where(:type_of => "bond ask", 
                   :goal_id => self.goal_id, 
                   :status => "pending").first
  end

  def find_matching_bid
    LineItem.where(:type_of => "bond bid", 
                   :goal_id => self.goal_id, 
                   :status => "pending").first
  end

  def execute!
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
      self.save!
    end
  end

end
