class LineItem < ApplicationRecord
  belongs_to :cart
  belongs_to :order
  belongs_to :account
  belongs_to :parent, :class_name => "LineItem"
  has_one    :child, :class_name => "LineItem", :foreign_key => :parent_id
  has_many :buys, :class_name => "Trade", :foreign_key => :bid_id
  has_many :sells, :class_name => "Trade", :foreign_key => :ask_id
  has_one :cancellation

  TYPES = ["bond bid", "bond ask", "swap bid", "swap ask"]
  UI_TYPES = ["bond bid", "bond ask", "swap bid"]  

  STATUSES = ["new", "pending", "executed", "cancelled"]

  validates :qty, :presence => true, :numericality => {:greater_than => 0, :less_than => 101}
  validates :max_bid_min_ask, :presence => true, :numericality => {:greater_than => 0}
  validates :account, :presence => true

  validate :enough_bonds_to_cover_cart_asks, :if => [:create, :update]
  validate :children_rules
  validate :swap_bids_must_bid_face
  
  after_create :create_bond_ask_for_swap_bid
  before_validation :sync_swap_bid_qty_to_bond_ask_qty
  after_update :sync_bond_ask_qty_to_swap_bid_qty

  def cancel!
    if self.status == "pending"
      case self.type_of
      when "swap bid"
        self.status = "cancelled"
        self.save!
        self.create_cancellation!
        self.child.status = "cancelled"
        self.child.save!  
        self.child.create_cancellation!
        swap = Bond.find_by_creditor_id_and_debtor_id(self.account.goal.escrow,
                                                      self.account)                          
        self.qty.times { swap.decrement! }
      #####################
      when "bond bid"
        self.account.goal.escrow.transfer_funds_to!(self.qty * self.max_bid_min_ask, 
                                                    self.account)
        self.status = "cancelled"
        self.save!
        self.create_cancellation!        
      #####################
      when "bond ask"
        if (self.parent && self.parent.status == "pending")
          self.parent.cancel! 
        else
          self.qty.times { self.account.goal.escrow.transfer_bond_to!(self.account) }
          self.status = "cancelled"
          self.save!
          self.create_cancellation!          
        end 
      #####################
      else    
        #wrong!
      end 
      self.account.goal.line_items.where(:status => "pending").order(:created_at).each do |li|
        li.reload.execute!
      end
    end
  end



  def find_matching_bond_asks
    matches = []
    asks = self.account.goal.line_items.where(:type_of => "bond ask",
                                              :status => "pending").where(
                                              "account_id != ?", self.account_id).where(
                                              "max_bid_min_ask <= ?", self.max_bid_min_ask).where(
                                              "qty <= ?", self.qty).order("created_at ASC, max_bid_min_ask ASC")

    used_bond_asks = asks.where(:parent_id => nil)
    swap_bond_asks = asks - used_bond_asks

    if self.max_bid_min_ask < self.account.goal.bond_face_value
      if self.account.is_bondholder?
        matches = swap_bond_asks + used_bond_asks
      else
        matches = swap_bond_asks  
      end
    else
      sbaqty = swap_bond_asks.inject(0){|sum, e| sum += e.qty }
      if sbaqty < self.qty
        treasury_ask = self.account.goal.treasury.line_items.create!(:type_of => "bond ask",
                                                                      :qty => self.qty - sbaqty,
                                                                      :max_bid_min_ask => self.account.goal.bond_face_value)
        treasury_ask.execute!
        matches = [treasury_ask]
      end
      matches = swap_bond_asks + matches
    end
  
    actual_matches(matches)
  end

  def find_matching_bond_bids
    return [] if self.account.goal.bond_face_value <= self.max_bid_min_ask
    matches = self.account.goal.line_items.where(:type_of => "bond bid",
                                                 :status => "pending").where(
                                                 "account_id != ?", self.account_id).where(
                                                 "max_bid_min_ask >= ?", self.max_bid_min_ask).where(
                                                 "qty <= ?", self.qty).order("created_at ASC, max_bid_min_ask DESC")
    actual_matches(matches)                                                              
  end

  def actual_matches(matches)
    #quit if there aren't enough
    return [] if matches.empty?

    mqty = matches.inject(0){|sum, e| sum += e.qty}
    
    return [] if mqty < self.qty

    actual_matches =[]
    q = self.qty
    matches.each do |m|
      if q == m.qty  #if qty is exact
        actual_matches << m
        return actual_matches
      elsif (q > m.qty)  #if we still need more than m.qty
        q -= m.qty
        actual_matches << m
      else # (qty < m.qty), create a new lineitem of qty and decrement m.qty by qty
      #   firstqty = LineItem.create! m.attributes.merge(:qty => q)
      #   m.qty -= q
      #   m.save!
      #   actual_matches << firstqty
      #   return actual_matches
      end    
    end
    if q == 0 
      return actual_matches                   
    else
      return []
    end
  end

  
  def execute!
    unless self.status == "executed" || self.status == "cancelled" || !self.cart.nil?

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
          m.parent.execute! unless m.parent.nil?
        end
        self.status = "executed" unless matches.empty?
        self.save!
        ##########################
      elsif type_of == "bond ask"
        if self.status == "new"
          # in case child attempts execution first, 
          #   check if it has a parent, attempt to execute parent so it pends first
          if !self.parent.nil? && self.parent.reload.status == "new"
            self.parent.execute! 
            return self
          end
          qty.times { self.account.transfer_bond_to!(self.account.goal.escrow) }             
          self.status = "pending"
          self.save!
        end
        matches = find_matching_bond_bids
        matches.each do |m|
          self.sells.create!(:bid => m, :qty => m.qty, :price => self.max_bid_min_ask)
          m.status = "executed"  
          m.save!
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
          return self if self.reload.status == "executed"
        end

        if self.child.reload.status == "executed"
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

  def best_case_pledge
    case self.type_of
    when "swap bid"
      return -self.qty * self.max_bid_min_ask
    when "bond bid"
      return (self.account.goal.bond_face_value - self.max_bid_min_ask) * self.qty
    when "bond ask"
      return self.qty * self.max_bid_min_ask
    end
  end

  def worst_case_pledge
    case self.type_of
    when "swap bid"
      return -self.qty * 2 * self.max_bid_min_ask 
    when "bond bid"
      return -self.qty * self.max_bid_min_ask
    when "bond ask"
      return self.qty * self.max_bid_min_ask
    end
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

  def enough_bonds_to_cover_cart_asks
    if self.type_of == "bond ask" && self.status == "new" && !self.parent_id && !self.account.is_treasury
      clis = self.account.line_items.where(:type_of => "bond ask", :parent_id => nil).where(:cart_id => self.account.user.cart.id)
      cart_qty = clis.sum(:qty)
      if self.qty + cart_qty > self.account.bond_qty
        self.errors.add(:qty, "If we added this to your cart, you'd be trying to sell more bonds than you own.")
      end
    end
  end

  def children_rules
    if self.parent_id 
      if self.type_of == "bond ask"
        errors.add(:qty, "must equal swap qty of #{self.parent.qty}.") if self.qty != self.parent.reload.qty
      else
        errors.add(:type_of, "must be bond ask if linked to a swap bid")
      end
    end
  end

  def sync_bond_ask_qty_to_swap_bid_qty
    if self.status == "new" && self.type_of == "swap bid" && self.changed.include?("qty") && (self.child.qty != self.qty)
      self.child.update_attributes!(:qty => self.qty)#, :validate => false)
    end
  end

  def sync_swap_bid_qty_to_bond_ask_qty
    if self.status == "new" && self.type_of == "bond ask" && self.parent
      if self.changed.include?("qty") && self.parent.qty != self.qty
        self.parent.qty = self.qty 
        self.parent.save!
      end
    end
  end

  def swap_bids_must_bid_face
    if self.type_of == "swap bid" && self.max_bid_min_ask < self.account.goal.bond_face_value
      errors.add(:max_bid_min_ask, "must be face value ($#{self.account.goal.bond_face_value})")
    end
  end

end
