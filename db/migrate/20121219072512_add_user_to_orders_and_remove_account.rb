class AddUserToOrdersAndRemoveAccount < ActiveRecord::Migration
  def self.up
    add_column :orders, :user_id, :integer
    remove_column :orders, :account_id
  end

  def self.down
    remove_column :orders, :user_id
    add_column :orders, :account_id, :integer
  end
end
