class AddPriceToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :price, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :orders, :price
  end
end
