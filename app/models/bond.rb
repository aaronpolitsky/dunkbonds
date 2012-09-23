class Bond < ActiveRecord::Base
  belongs_to :goal
  belongs_to :creditor, :class_name => "Account", :foreign_key => "creditor_id"
  belongs_to :debtor,   :class_name => "Account", :foreign_key => "debtor_id"

  def pay_coupons
    Account.transaction do
      creditor.balance += qty
      debtor.balance -= qty
      creditor.save!
      debtor.save!
    end
  end

end
