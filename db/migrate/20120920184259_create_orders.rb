class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :account_id
      t.string :status
      t.string :type_of
      t.decimal :bid_ask, :precision => 8, :scale => 2
      t.integer :goal_id
      t.decimal :price, :precision => 8, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
