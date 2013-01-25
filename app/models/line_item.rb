class LineItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :order
  belongs_to :account
  belongs_to :parent, :class_name => "LineItem"
  has_one    :child, :class_name => "LineItem", :foreign_key => :parent_id
  has_many :buys, :class_name => "Trade", :foreign_key => :bid_id
  has_many :sells, :class_name => "Trade", :foreign_key => :ask_id


  TYPES = ["bond bid", "bond ask", "swap bid", "swap ask"]

  STATUSES = ["new", "pending", "executed", "cancelled"]

  validates :qty, :presence => true, :numericality => {:greater_than => 0, :less_than => 101}
  validates :max_bid_min_ask, :presence => true, :numericality => {:greater_than => 0}
  validates :account, :presence => true

  after_create :create_bond_ask_for_swap_bid

  def cancel!
    if self.status == "pending"
      case self.type_of
      when "swap bid"
        self.status = "cancelled"
        self.save!
        self.child.status = "cancelled"
        self.child.save!  
        swap = Bond.find_by_creditor_id_and_debtor_id(self.account.goal.escrow,
                                                      self.account)                          
        self.qty.times { swap.decrement! }
      #####################
      when "bond bid"
        self.account.goal.escrow.transfer_funds_to!(self.qty * self.max_bid_min_ask, 
                                                    self.account)
        self.status = "cancelled"
        self.save!
      #####################
      when "bond ask"
        if (self.parent && self.parent.status == "pending")
          self.parent.cancel! 
        else
          self.qty.times { self.account.goal.escrow.transfer_bond_to!(self.account) }
          self.status = "cancelled"
          self.save!
        end 
      #####################
      else    
        #wrong!
      end 
    end
  end



  def find_matching_bond_asks

    asks = self.account.goal.line_items.where(:type_of => "bond ask",
                                              :status => "pending").where(
                                              "account_id != ?", self.account_id).where(
                                              "max_bid_min_ask <= ?", self.max_bid_min_ask).where(
                                              "qty <= ?", self.qty).order("created_at ASC, max_bid_min_ask ASC")

    used_bond_asks = asks.where(:parent_id => nil)
    swap_bond_asks = asks - used_bond_asks
    if self.max_bid_min_ask < self.account.goal.bond_face_value
      matches = swap_bond_asks + used_bond_asks
    else
    #   sbaqty = swap_bond_asks.inject(0){|sum, e| sum += e.qty }
    #   treasury_ask = self.account.goal.treasury.line_items.create!(:type_of => "bond ask",
    #                                                                 :qty => self.qty - sbaqty,
    #                                                                 :max_bid_min_ask => self.account.goal.bond_face_value)
    #   treasury_ask.execute!
    #   matches = swap_bond_asks + [treasury_ask]
    end
  
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

    return [] if matches.empty?

    #quit if there aren't enough
    mqty = matches.inject(0){|sum, e| sum += e.qty}
    # matches.each do |m|
    #   mqty += m.qty
    # end
    return [] if mqty < self.qty

    bestmatches =[]
    q = self.qty
    matches.each do |m|
      if q == m.qty  #if qty is exact
        bestmatches << m
        return bestmatches
      elsif (q > m.qty)  #if we still need more than m.qty
        q -= m.qty
        bestmatches << m
      else # (qty < m.qty), create a new lineitem of qty and decrement m.qty by qty
        firstqty = LineItem.create! m.attributes.merge(:qty => q)
        m.qty -= q
        m.save!
        bestmatches << firstqty
        return bestmatches
      end    
    end    
    return bestmatches                   
  end

  def find_matching_bond_bids
    return [] if self.account.goal.bond_face_value <= self.max_bid_min_ask
    matches = self.account.goal.line_items.where(:type_of => "bond bid",
                                                 :status => "pending").where(
                                                 "account_id != ?", self.account_id).where(
                                                 "max_bid_min_ask >= ?", self.max_bid_min_ask).where(
                                                 "qty <= ?", self.qty).order("created_at ASC, max_bid_min_ask DESC")
  end

  def execute!
    unless self.status == "executed" || !self.cart.nil?

      if type_of == "bond bid"
        if self.status == "new"
          self.account.transfer_funds_to!(self.qty * self.max_bid_min_ask,
                                          self.account.goal.escrow) 
          self.status = "pending"
        end
        matches = find_matching_bond_asks
        matches.each do |m|
          self.buys.create!(:ask => m, :qty => m.qty, :price => m.max_bid_min_ask)
          m.status = "executed"  
          m.save!
        end
        self.status = "executed" unless matches.empty?
        self.save!
        ##########################
      elsif type_of == "bond ask"
        if self.status == "new"
          # in case child attempts execution first, 
          #   check if it has a parent, attempt to execute parent so it pends first
          if !self.parent.nil? && self.parent.status == "new"
            self.parent.execute! 
            return self
          end
          qty.times { self.account.transfer_bond_to!(self.account.goal.escrow) }             
          self.status = "pending"
          self.save!
        end
        matches = find_matching_bond_bids
        matches.each do |m|
          self.sells.create!(:bid => m, :qty => m.qty, :price => m.max_bid_min_ask)
        end
        self.status = "executed" unless matches.empty?
        self.save!
        if self.status == "executed"
          self.parent.execute! unless self.parent.nil? 
        end
        ##########################
      elsif type_of == "swap bid"
        if self.status == "new"
          qty.times { self.account.goal.treasury.transfer_swap_to!(self.account) }
          self.status = "pending"
          self.save!
          self.child.execute!
          return self if self.status == "executed"
        end

        if self.child.status == "executed"
          m = self.account.goal.treasury.line_items.create!(:qty => self.qty,
                                                        :type_of => "swap ask",
                                                        :status => "pending",
                                                        :max_bid_min_ask => self.account.goal.bond_face_value)
          self.buys.create!(:ask => m, :qty => m.qty, :price => m.max_bid_min_ask)
          self.status = 'executed'
        end
        self.save!
      elsif type_of == "swap ask"

      end
    end
    self
  end

  private

  def create_bond_ask_for_swap_bid
    if self.type_of == "swap bid" 
      self.create_child(:type_of => "bond ask",
                       :account_id => self.account.id,
                       :qty => self.qty,
                       :max_bid_min_ask => self.account.goal.bond_face_value)
    end
  end
end
