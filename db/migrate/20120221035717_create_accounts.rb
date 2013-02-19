class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :user_id
      t.decimal :initial_balance, :precision => 8, :scale => 2
      t.decimal :balance, :precision => 8, :scale => 2
      t.integer :updated_by
      t.boolean :is_escrow, :default => false
      t.boolean :is_treasury, :default => false
      t.boolean :is_soft_deleted, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
