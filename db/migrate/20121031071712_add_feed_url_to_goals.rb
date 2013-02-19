class AddFeedUrlToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :feed_url, :string
  end

  def self.down
    remove_column :goals, :feed_url
  end
end
