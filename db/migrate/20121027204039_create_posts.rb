class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :goal_id
      t.string :title
      t.text :content
      t.string :url
      t.datetime :published_at
      t.string :guid
      t.boolean :is_visible, :default => true

      t.timestamps
    end

    add_index :posts, [:guid]
  end


  def self.down
    drop_table :posts
  end
end
