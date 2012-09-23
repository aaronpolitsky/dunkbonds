class Account < ActiveRecord::Base
  # A bond is just a link between two accounts establishing a payment flow
  # A swap is the same link seen from the other perspective.  

  belongs_to :goal
  has_many :bonds, :foreign_key => :creditor_id # a creditor owns bonds and collects payments from debtors
  has_many :swaps, :class_name => "Bond", :foreign_key => :debtor_id # a debtor pays a creditor periodically, also the same as a swap

  def sell_swap(buyer)
    swap = self.swaps.first
    swap.debtor_id = buyer.id
    self.balance += 10.0
    buyer.balance -= 10.0
    swap.save!
  end

  def sell_bond!(buyer)
    Account.transaction do
      if Bond.exists?(:creditor_id => buyer.id,
                      :debtor_id => self.id, 
                      :goal_id => self.goal.id)
        bond = buyer.bonds.where(:debtor_id => self.id, :goal_id => self.goal.id).first
        bond.qty += 1
      else
        #this creates a new bond-swap link rather than transferring ownership.  could be a bad idea, could be just fine. 
        bond = buyer.bonds.create!(:debtor_id => self.id, 
                                   :goal_id => self.goal.id, 
                                   :qty => 1)
      end
      self.balance += 10.0
      buyer.balance -= 10.0
      self.save!
      buyer.save!
      bond.save!
    end
  end

end
