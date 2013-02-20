class ChangeGoals < ActiveRecord::Migration

  def change
    add_column :goals, :title, :string
    add_column :goals, :period, :string
    add_column :goals, :blog_service_provider, :string
    
    rename_column :goals, :creator_id, :goalsetter_id
    rename_column :goals, :start_date, :starts_at
    rename_column :goals, :goal_date, :ends_at  
    rename_column :goals, :feed_url, :blog_url

    add_index :goals, [:goalsetter_id]

    Goal.reset_column_information
    g = Goal.find 1
    g.title = "Aaron DUNKs"
    g.description = "Aaron DUNKs an NBA-size basketball on a regulation hoop by March 1st, 2013.  No trampolines."
    g.goalsetter_id = 2
    g.period = '1 month'
    g.save!
  end


  # def self.up
  #   create_table :goals do |t|
  #     t.string :title
  #     t.text :description
  #     t.datetime :starts_at
  #     t.datetime :ends_at
  #     t.string :period
  #     t.integer :goalsetter_id

  #     t.timestamps
  #   end

  #   add_index :goals, [:goalsetter_id]
  # end


  # def self.down
  #   drop_table :goals
  # end

end
