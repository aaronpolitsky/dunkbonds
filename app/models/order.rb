class Order < ActiveRecord::Base
  belongs_to :user
#  has_many :line_items, :dependent => :destroy

  def get_cart_items
    self.user.cart.line_items.each do |item|
      item.cart_id = nil
      self.line_items << item
    end
    self.save!
  end

  def execute_line_items
    self.line_items.each do |item|
      item.reload.execute!
    end
  end

  def attempt_to_execute_all_pending_line_items 
    self.line_items.where(:status => "pending").each do |pli|
      goal = pli.account.goal
      pending_goal_line_items = goal.line_items.where(:status => "pending").order(:created_at) - [pli]
      pending_goal_line_items.each do |li|
        li.reload.execute!
      end
    end
  end
end
