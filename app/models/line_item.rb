class LineItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :order
  belongs_to :account
  has_many :buys, :class_name => "Trade", :foreign_key => :bid_id
  has_many :sells, :class_name => "Trade", :foreign_key => :ask_id

  TYPES = ["bond bid", "bond ask",
           "swap bid", "swap ask"]

  STATUSES = ["new", 
              "pending",
              "executed",
              "cancelled"]
  
  validates :qty, :presence => true, :numericality => {:greater_than => 0, :less_than => 101}

  def cancel!
    if self.status == "pending"
      self.status = "cancelled"
      self.save!
    end
  end

  def find_matching_asks
    #first match by ask, goal, and pending status
    matches = self.account.goal.line_items.where(:type_of => "bond ask", :status => "pending").where("account_id != ?", self.account)

    #then pare down by price
    matches = matches.where('max_bid_min_ask <= ?', self.max_bid_min_ask).order(:created_at)

    return [] if matches.empty?
    #quit if there aren't enough
    return [] if matches.sum(:qty) < self.qty

    bestmatches =[]
    qty = self.qty
    matches.each do |m|
      if qty == m.qty  #if qty is exact
        bestmatches << m
        return bestmatches
      elsif (qty > m.qty)  #if we still need more than m.qty
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
        matches.each do |m|

          self.buys.create!(:ask => m, :qty => m.qty, :price => m.max_bid_min_ask)        

          # m.qty.times do #easier to call it mult times than to build qty into it
          #   m.account.sell_bond!(self.account)
          # end
          # self.status = m.status = "executed"
          # m.save!
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

end
