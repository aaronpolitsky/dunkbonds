class LineItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :order
  belongs_to :account
  has_many :buys, :class_name => "Trade", :foreign_key => :bid_id
  has_many :sells, :class_name => "Trade", :foreign_key => :ask_id

  TYPES = ["bond bid", "bond ask", "swap bid", "swap ask"]

  STATUSES = ["new", "pending", "executed", "cancelled"]

  validates :qty, :presence => true, :numericality => {:greater_than => 0, :less_than => 101}
  validates :account, :presence => true

  def cancel!
    if self.status == "pending"
      self.status = "cancelled"
      self.save!
    end
  end

  def find_matching_bond_asks
    #first match by ask, goal, and pending status
#     used_bonds = self.account.goal.line_items.where(:type_of => "bond ask",
#                                                     :status => "pending").where(
#                                                     "account_id != ?", self.account).where(
#                                                     "max_bid_min_ask <= ?", self.max_bid_min_ask).order(
#                                                     :created_at)

#     #swap bids are psuedo bond asks
#     swap_bids = self.account.goal.line_items.where(:type_of => "swap_bid",
#                                                    :status => "pending").where(
#                                                    "account_id != ?", self.account).where(
#                                                    "max_bid_min_ask <= ?", self.max_bid_min_ask).order(
#                                                    :created_at)

# ######### thoughts
#     # matches = swap_bids # to start

#     # # if offering $face, treasury can sell bonds, so add them
#     # if self.max_bid_min_ask >= @goal.bond_face_value 
#     #   # how many does treasury need to fill, total?
#     #   qty_needed = self.qty - swap_bids.sum(:qty) - used_bonds.sum(:qty)

#     #   unless self.account.is_bondholder? 
#     #     #gotta buy at least one from treasury before you buy used bonds
#     #     matches += @treasury.line_items.create!(:qty => 1,
#     #                                             :type_of => "bond ask",
#     #                                             :status => "pending",
#     #                                             :max_bid_min_ask => @goal.bond_face_value)


#     #   end

#     #   if qty_needed > 0 

#     #   end
#     # end


#     # matches ++ bond_asks #in that order


#     #  
#     ######### / thoughts

    matches = self.account.goal.line_items.where(:type_of => "bond ask", 
                                                 :status => "pending").where(
                                                 "account_id != ?", self.account
                                                 )

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

  def find_matching_bond_bids
    matches = self.account.goal.line_items.where(:type_of => "bond bid",
                                                 :status => "pending").where(
                                                 "account_id != ?", self.account_id).where(
                                                 "max_bid_min_ask >= ?", self.max_bid_min_ask).where(
                                                 "qty <= ?", self.qty)
  end

  def execute!
    unless status == "executed"
      self.status = "pending"

      if type_of == "bond bid"
        self.account.transfer_funds_to!(self.qty * self.max_bid_min_ask,
                                        self.account.goal.escrow)
        matches = find_matching_bond_asks
        matches.each do |m|
          self.buys.create!(:ask => m, :qty => m.qty, :price => m.max_bid_min_ask)
          m.status = "executed"  
          m.save!
        end
        self.status = "executed" unless matches.empty?
      elsif type_of == "bond ask"
        qty.times do |q|
          self.account.transfer_bond_to!(self.account.goal.escrow) 
        end
        matches = find_matching_bond_bids
        matches.each do |m|
          self.sells.create!(:bid => m, :qty => m.qty, :price => m.max_bid_min_ask)
        end
        self.status = "executed" unless matches.empty?
      elsif type_of == "swap bid"


        

      elsif type_of == "swap ask"

      end
      self.save!
    end
  end

end
