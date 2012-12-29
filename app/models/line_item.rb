class LineItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :order
  belongs_to :goal

  TYPES = ["bond bid", "bond ask",
           "swap bid", "swap ask"]

  STATUSES = ["new", 
              "in cart",
              "pending",
              "executed",
              "cancelled"]
  
  validate :qty_is_valid

  def account
    self.user.account.find_by_goal(self.goal)
  end

  def find_matching_asks
    #first match by ask, goal, and pending status
    matches = LineItem.where(:type_of => "bond ask", 
                             :goal_id => self.goal_id, 
                             :status => "pending")

    #then pare down by price
    matches = matches.where('max_bid_min_ask <= ?', self.max_bid_min_ask).order(:created_at)

    #quit if there aren't enough
    return [] if matches.sum(:qty) < self.qty

    bestmatches =[]
    qty = self.qty
    matches.each do |m|
      if qty == m.qty
        bestmatches << m
        return bestmatches
      elsif (qty > m.qty) 
        qty -= m.qty
        bestmatches << m
      else  #(qty < m.qty), create a new lineitem of qty and decrement m.qty by qty
        firstqty = LineItem.create! m.attributes.merge(:qty => qty)
        m.qty -= qty
        m.save!
        bestmatches << firstqty
        return bestmatches
      end    
    end    
    return bestmatches                   
  end

  def find_matching_bids
    LineItem.where(:type_of => "bond bid", 
                   :goal_id => self.goal_id, 
                   :status => "pending")
  end

  def execute!
    unless status == "executed"
      self.status = "pending"
      if type_of == "bond bid"
        matches = find_matching_asks
        unless matches.emtpy?
          matches.each do |m|
            m.account.sell_bond!(self.account)
            self.status = match.status = "executed"
            match.save!
          end
        end
        
      elsif type_of == "bond ask"
        matches = find_matching_bids
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

  private

  def qty_is_valid
    !self.qty.nil? && self.qty > 0 && self.qty <= 100
  end

end
