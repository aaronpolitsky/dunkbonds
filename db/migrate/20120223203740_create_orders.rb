class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :account_id
      t.string :type_of
      t.string :status
      t.decimal :max_bid, :precision => 8, :scale => 2
      t.decimal :min_ask, :precision => 8, :scale => 2
      t.integer :updated_by
      t.boolean :is_deleted, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
