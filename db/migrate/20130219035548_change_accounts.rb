class ChangeAccounts < ActiveRecord::Migration
	def up
		add_column :accounts, :goal_id, :integer
		change_column :accounts, :balance, :decimal, :precision => 8, :scale => 2, :default => 0.0
		remove_column :accounts, :is_soft_deleted, :initial_balance, :updated_by
		add_index :accounts, [:user_id, :goal_id], :unique => true, :name => "user_goal"
  end

  def down
		add_column :accounts, :is_soft_deleted, :boolean, :default => false
		add_column :accounts, :initial_balance, :decimal, :precision => 8, :scale => 2, :default => 0
		add_column :accounts, :updated_by, :integer
		remove_column :accounts, :goal_id
		change_column :accounts, :balance, :decimal, :precision => 8, :scale => 2
  end  
end
