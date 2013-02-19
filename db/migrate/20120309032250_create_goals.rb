class CreateGoals < ActiveRecord::Migration
  def self.up
    create_table :goals do |t|
      t.integer :creator_id
      t.string :type_of
      t.text :description
      t.datetime :start_date
      t.datetime :goal_date
      t.boolean :is_completed, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :goals
  end
end
