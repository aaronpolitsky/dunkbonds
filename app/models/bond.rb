class Bond < ActiveRecord::Base
  # belongs_to :goal
  belongs_to :creditor, :class_name => "Account", :foreign_key => "creditor_id"
  belongs_to :debtor,   :class_name => "Account", :foreign_key => "debtor_id"

  validate :goals_agree?
  validate :creditor_or_debtor_present?

  def pay_coupons
    #create receipts, see dunkbonds 1.0
    Account.transaction do
      creditor.balance += qty
      debtor.balance -= qty
      creditor.save!
      debtor.save!
    end
  end

  private

  def goals_agree?
    unless (self.creditor.nil? || self.debtor.nil?) 
      unless self.creditor.goal == self.debtor.goal
        errors.add(:bond, "Creditor and Debtor goals must agree")
      end
    end
  end

  def creditor_or_debtor_present?
    if (self.creditor.nil? && self.debtor.nil?) 
      errors.add(:bond, "Either Creditor or Debtor must exist.")
    end 
  end
end
