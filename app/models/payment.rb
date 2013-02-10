class Payment < ActiveRecord::Base
	belongs_to :payee, :class_name => "Account", :foreign_key => "payee_id"
  belongs_to :recipient, :class_name => "Account", :foreign_key => "recipient_id"

  validates :amount, :presence => true, :numericality => {:greater_than => 0.0, :less_than => 101}
  validates :payee, :presence => true
  validates :recipient, :presence => true  
  
  after_create :pay

  private 

  def pay
  	# Transaction.do |p|
			self.payee.debit!(self.amount)
			self.recipient.credit!(self.amount)
  	# end
  end

end
