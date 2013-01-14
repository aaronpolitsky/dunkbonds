class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.integer :bid_id
      t.integer :ask_id
      t.integer :qty
      t.decimal :price, :precision => 8, :scale => 2

      t.timestamps
    end

    add_index :trades, [:bid_id, :ask_id], :name => "bid_ask"
  end
end
