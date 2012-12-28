class RemoveAccountIdFromLineItems < ActiveRecord::Migration
  def self.up
#    remove_column :line_items, :account_id
  end

  def self.down
#    add_column :line_items, :account_id, :integer
  end
end
