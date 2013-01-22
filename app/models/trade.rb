class Trade < ActiveRecord::Base
  belongs_to :bid, :class_name => "LineItem", :foreign_key => "bid_id"
  belongs_to :ask, :class_name => "LineItem", :foreign_key => "ask_id"

  validates :qty, :presence => true, :numericality => {:greater_than => 0}
  validates :price, :presence => true, :numericality => {:greater_than => 0}
  validates :bid, :presence => true
  validates :ask, :presence => true

  after_create :execute

  def total
    price * qty
  end

  private

  def execute
  	#do whatever changing of hands the trade requires here
    if self.bid.type_of == "bond bid"
      self.qty.times do
        self.bid.account.goal.escrow.transfer_bond_to!(self.bid.account)
      end
      self.bid.account.goal.escrow.transfer_funds_to!(self.price * self.qty, 
                                                      self.ask.account)
    else #swap bid
      self.qty.times do
        self.bid.account.goal.escrow.transfer_swap_to!(self.bid.account)
      end
      self.bid.account.goal.escrow.transfer_funds_to!(self.price * self.qty, 
                                                      self.ask.account)
    end
  end

end
