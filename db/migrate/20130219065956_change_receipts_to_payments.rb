class ChangeReceiptsToPayments < ActiveRecord::Migration
  def up
  	rename_column :receipts, :payee_id, :recipient_id
  	remove_column :receipts, :goal_id, :is_executed
  	change_column :receipts, :amount, :decimal, :precision => 8, :scale => 2, :default => 0.0
  	rename_table :receipts, :payments
  end

  def down
  	rename_table :payments, :receipts
  	change_column :receipts, :amount, :decimal, :precision => 8, :scale => 2
  	add_column :receipts, :goal_id, :integer
  	add_column :receipts, :is_executed, :boolean
  	rename_column :receipts, :recipient_id, :payee_id
  end
end
