class AddGoalToBonds < ActiveRecord::Migration
  def self.up
    add_column :bonds, :goal_id, :integer
  end

  def self.down
    remove_column :bonds, :goal_id
  end
end
