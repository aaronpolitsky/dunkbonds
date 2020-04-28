class Payment < ApplicationRecord
	belongs_to :payer, :class_name => "Account", :foreign_key => "payer_id"
  belongs_to :recipient, :class_name => "Account", :foreign_key => "recipient_id"

  validates :amount, :presence => true, :numericality => {:greater_than => 0.0, :less_than => 101}
  validates :payer, :presence => true
  validates :recipient, :presence => true  
  
  after_create :pay

  private 

  def pay
  	# Transaction.do |p|
			self.payer.debit!(self.amount)
			self.recipient.credit!(self.amount)
  	# end
  end

end
