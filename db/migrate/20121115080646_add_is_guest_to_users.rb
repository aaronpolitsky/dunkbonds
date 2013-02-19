class AddIsGuestToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_guest, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_guest
  end
end
