class CreateReceipts < ActiveRecord::Migration
  def self.up
    create_table :receipts do |t|
      t.integer :payee_id
      t.integer :payer_id
      t.integer :goal_id
      t.boolean :is_executed, :default => false
      t.decimal :amount, :precision => 8, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :receipts
  end
end
