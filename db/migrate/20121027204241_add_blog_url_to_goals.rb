class AddBlogUrlToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :blog_url, :string
  end

  def self.down
    remove_column :goals, :blog_url
  end
end
