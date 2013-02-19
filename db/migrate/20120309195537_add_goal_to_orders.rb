class AddGoalToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :goal_id, :integer
  end

  def self.down
    remove_column :orders, :goal_id
  end
end
