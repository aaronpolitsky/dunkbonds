class Bond < ApplicationRecord
  # belongs_to :goal
  belongs_to :creditor, :class_name => "Account", :foreign_key => "creditor_id"
  belongs_to :debtor,   :class_name => "Account", :foreign_key => "debtor_id"

  validate :goals_agree?
  validate :creditor_or_debtor_present?

  def pay_coupons
    #this assumes that today we pay the bonds based on yesterday's face value
    self.debtor.payments.create!(:recipient => self.creditor,
                                 :amount => self.qty) if self.creditor.goal.period == '1 month'
  end

  def decrement!
    self.qty -= 1 if self.qty > 0
    self.save!
    self.destroy if self.qty.zero?
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
