class AddBondToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :bond_id, :integer
  end

  def self.down
    remove_column :orders, :bond_id
  end
end
