class Account < ActiveRecord::Base
  belongs_to :goal
  has_many :bonds, :foreign_key => :debtor_id # a debtor owns bonds and pays creditor
  has_many :swaps, :class_name => "Bond", :foreign_key => :creditor_id # a creditor pays a debtor periodically, also the same as a swap

  def sell_swap(buyer)
#    if Bond.exists?(:creditor_id => self, :debtor_id => buyer, :goal_id => self.goal)
#      bond = self.bonds.where(:debtor_id => buyer, :goal_id => self.goal_id).first
#    else
#      bond = self.bonds.where(:goal_id => self.goal_id).first
#    end
    swap = Bond.where(:creditor_id => self.id).first
    self.balance += 10.0
    buyer.balance -= 10
    swap.new_creditor!(buyer.id)
  end

  def sell_bond(buyer)
    #transaction
    bond = Bond.where(:debtor_id => self.id).first  #TODO find if exists
    self.balance += 10.0
    buyer.balance -= 10.0
    bond.new_debtor!(buyer.id)
    #end transaction
  end

end
