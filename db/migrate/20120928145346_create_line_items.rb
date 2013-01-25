class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.string :status, :default => "new"
      t.string :type_of
      t.decimal :max_bid_min_ask, :precision => 8, :scale => 2
      t.integer :account_id
      t.integer :cart_id
      t.integer :order_id
      t.integer :qty
      t.integer :parent_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end
