class AddUniqueIndexToAccount < ActiveRecord::Migration
  def self.up
    add_index :accounts, [:user_id, :goal_id], :unique => true, :name => "user_goal"
  end

  def self.down
    remove_index :accounts, "user_goal"
  end
end
