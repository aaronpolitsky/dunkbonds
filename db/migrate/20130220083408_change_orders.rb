class ChangeOrders < ActiveRecord::Migration
  def up
  	change_table :orders do |t|
  		t.remove :account_id, :type_of, :status, :max_bid, :min_ask, :updated_by, :is_deleted, :goal_id, :bond_id, :price, :match_id
		end	
  end

  def down
  	change_table :orders do |t|
  		t.integer :account_id
  		t.string  :type_of
  		t.string  :status
  		t.decimal :max_bid, :precision => 8, :scale => 2
  		t.decimal :min_ask, :precision => 8, :scale => 2
  		t.integer :updated_by
  		t.boolean :is_deleted, :default => false
  		t.integer :goal_id
  		t.integer :bond_id
  		t.decimal :price, :precision => 8, :scale => 2
  		t.integer :match_id
  	end
  end
end
