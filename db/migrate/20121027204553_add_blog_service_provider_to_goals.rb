class AddBlogServiceProviderToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :blog_service_provider, :string
  end

  def self.down
    remove_column :goals, :blog_service_provider
  end
end
