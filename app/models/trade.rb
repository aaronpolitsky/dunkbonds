class Trade < ActiveRecord::Base
  belongs_to :bid, :class_name => "LineItem", :foreign_key => "bid_id"
  belongs_to :ask, :class_name => "LineItem", :foreign_key => "ask_id"

  validates :qty, :presence => true, :numericality => {:greater_than => 0}
  validates :price, :presence => true, :numericality => {:greater_than => 0}
  validates :bid, :presence => true
  validates :ask, :presence => true

  after_create :execute

  private

  def execute
  	#do whatever changing of hands the trade requires here
    bid.account.debit!(qty * price)
    ask.account.credit!(qty * price)
  end

end
