class Bond < ActiveRecord::Base
  belongs_to :goal
  belongs_to :creditor_id, :class_name => Account
  belongs_to :debtor_id,   :class_name => Account

  attr_accessible :creditor_id, :debtor_id

  def new_creditor!(creditor)
    :creditor_id = creditor
    save!
  end

  def new_debtor!(debtor)
    :debtor_id = debtor
    save!
  end
end
