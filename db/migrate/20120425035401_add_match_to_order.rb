class AddMatchToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :match_id, :integer
  end

  def self.down
    remove_column :orders, :match_id
  end
end
