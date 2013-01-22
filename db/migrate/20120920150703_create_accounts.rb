class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :goal_id
      t.boolean :is_treasury, :default => false
      t.boolean :is_escrow, :default => false
      t.decimal :balance, :precision => 8, :scale => 2, :default => 0.0
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
