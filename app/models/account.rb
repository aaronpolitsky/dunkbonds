class Account < ActiveRecord::Base
  # A bond is just a link between two accounts establishing a payment flow
  # A swap is the same link seen from the other perspective.  

  belongs_to :goal
  has_many :orders
  has_many :bonds, :foreign_key => :creditor_id # a creditor owns bonds and collects payments from debtors
  has_many :swaps, :class_name => "Bond", :foreign_key => :debtor_id # a debtor pays a creditor periodically, also the same as a swap
  has_many :line_items

  def sell_swap(buyer)

  end

  def sell_bond!(buyer)
#    Account.transaction do
      if self.is_treasury?
        # increment qty if bond relationship already exists
        if Bond.exists?(:creditor_id => buyer.id,
                        :debtor_id => self.id, 
                        :goal_id => self.goal.id)
          bond = buyer.bonds.where(:debtor_id => self.id, :goal_id => self.goal.id).first
          bond.qty += 1
          bond.save!
        else
          #create a new bond-swap relationship
          bond = buyer.bonds.create!(:debtor_id => self.id, 
                                     :goal_id => self.goal.id, 
                                     :qty => 1)
          bond.save!
        end
#        self.balance += 10.0
#        buyer.balance -= 10.0
#        self.save!
#        buyer.save!
      else #regular accounts, secondary market
        #these sell their end of the bond-swap relationship, if they have any to sell
        if (self.bonds.sum(:qty) > 0)
          bond = self.bonds.where(:goal_id => self.goal.id).first
          if (bond.qty > 1)
            bond.qty -= 1
            bond.save!
            if (buyer.bonds.where(:goal_id => self.goal.id).sum(:qty) == 0)
              bond = buyer.bonds.create!(:debtor_id => self.id, 
                                         :goal_id => self.goal.id, 
                                         :qty => 1)
              bond.save!
            else
              buyer_bond = buyer.bonds.where(:goal_id => self.goal.id).first
              buyer_bond.qty += 1              
              buyer_bond.save!
            end
          else #if only one left, transfer it
            buyer.bonds << bond
          end

        else
          #this is the error case, just to make sure my test tests the right thing. 
#          bond = buyer.bonds.create!(:debtor_id => buyer.goal(:treasury), 
#                                     :goal_id => buyer.goal.id, 
#                                     :qty => 1)
        end
      end
#    end
  end

end

