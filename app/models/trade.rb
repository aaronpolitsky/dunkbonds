class Trade < ApplicationRecord
  belongs_to :bid, :class_name => "LineItem", :foreign_key => "bid_id"
  belongs_to :ask, :class_name => "LineItem", :foreign_key => "ask_id"

  validates :qty, :presence => true, :numericality => {:greater_than => 0}
  validates :price, :presence => true, :numericality => {:greater_than => 0}
  validates :bid, :presence => true
  validates :ask, :presence => true
  validate :type_of_bid

  after_create :execute

  def total
    self.price.to_s.to_d * self.qty.to_s.to_d
  end

  private

  def execute
  	#do whatever changing of hands the trade requires here
    if self.bid.type_of == "bond bid"
      escrow = self.bid.account.goal.escrow
      self.qty.times do
        escrow.transfer_bond_to!(self.bid.account)
      end
      escrow.transfer_funds_to!(self.total, 
                                self.ask.account)
      escrow.transfer_funds_to!(self.qty * (self.bid.max_bid_min_ask - self.price), 
                                self.bid.account)
    elsif self.bid.type_of == "swap bid"
      self.bid.account.transfer_funds_to!(self.total, self.ask.account)
    end
  end

  def type_of_bid
    return false if self.bid.nil?
    return false if self.bid.type_of.nil? 
    self.bid.type_of == "bond bid" || self.bid.type_of == "swap bid"
  end

end
