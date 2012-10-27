class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :goal_id
      t.string :title
      t.text :description
      t.string :link
      t.datetime :pubDate
      t.string :guid
      t.boolean :is_visible, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
