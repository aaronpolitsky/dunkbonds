class AddGetsEmailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gets_email, :boolean, :default => true
  end

  def self.down
    remove_column :users, :gets_email
  end
end
