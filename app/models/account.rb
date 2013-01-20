class Account < ActiveRecord::Base
  # A bond is just a link between two accounts establishing a payment flow
  # A swap is the same link seen from the other perspective.  

  belongs_to :user
  belongs_to :goal
  has_many :orders, :through => :user
  has_many :bonds, :foreign_key => :creditor_id # a creditor owns bonds and collects payments from debtors
  has_many :swaps, :class_name => "Bond", :foreign_key => :debtor_id # a debtor pays a creditor periodically, also the same as a swap
  has_many :line_items

  before_destroy :empty_account?, :order => :first

  def credit!(amt)
    self.balance += amt
    self.save!
  end

  def debit!(amt)
    self.balance -= amt
    self.save!
  end

  
  def transfer_swap_to!(buyer)
    if self.is_treasury?
      buyer_swap = Bond.find_or_create_by_creditor_id_and_debtor_id(buyer.id, buyer.id)
      buyer_swap.qty += 1
      buyer_swap.save!
    else
      if self.swaps.count > 0
        # if self.swaps.exists?(:creditor_id => buyer.id)
        #   debugger
        #   bondswap = self.swaps.find_by_creditor_id(buyer.id)
        #   if bondswap.qty == 1
        #     bondswap.destroy
        #   else 
        #   #   bondswap.qty -= 1
        #   #   bondswap.save!
        #   end
        # else  
        seller_swap = self.swaps.first
        buyer_swap = buyer.swaps.find_or_create_by_creditor_id(seller_swap.creditor_id)
        buyer_swap.qty += 1
        buyer_swap.save!
        if (seller_swap.qty > 1)
          seller_swap.qty -= 1
          seller_swap.save!
        else #if qty == 1
          seller_swap.destroy
        end
        # end
      end
    end
  end

  def transfer_bond_to!(buyer)
    if self.is_treasury?
      #find or create unique bond and increment
      buyer_bond = Bond.find_or_create_by_creditor_id_and_debtor_id(buyer.id, self.id)
      buyer_bond.qty += 1 
      buyer_bond.save!
    else #regular accounts, secondary market
    #these sell their bond end of the bond-swap relationship, if they have any to sell
      if (self.bonds.sum(:qty) > 0)
        bond = self.bonds.first #any will do
        if (bond.qty > 1)
          buyer_bond = buyer.bonds.find_or_create_by_debtor_id(bond.debtor_id)            
          bond.qty -= 1
          bond.save!
          buyer_bond.qty += 1            
          buyer_bond.save!
        else #if only one left, transfer it
          buyer_bond = buyer.bonds.find_or_create_by_debtor_id(bond.debtor_id)            
          buyer_bond.qty += 1            
          buyer_bond.save!
          bond.destroy
        end
      end
    end
  end

  private
  
  def empty_account?
    errors.add(:base, "This account cannot be closed because it has bonds.") unless self.bonds.empty?
    errors.add(:base, "This account cannot be closed because it has swaps.") unless self.swaps.empty?
    errors.add(:base, "This account cannot be closed because it has pending orders.") unless self.line_items.where(:status => "pending").empty?
    errors.blank?
  end


end

