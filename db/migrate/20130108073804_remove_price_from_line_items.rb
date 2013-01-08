class RemovePriceFromLineItems < ActiveRecord::Migration
  def up
  	remove_column :line_items, :price
  end

  def down
  	add_column :line_items, :price, :decimal, :precision => 8, :scale => 2
  end
end
