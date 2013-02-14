class CreateGoals < ActiveRecord::Migration
  def self.up
    create_table :goals do |t|
      t.string :title
      t.text :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :period
      t.integer :goalsetter_id

      t.timestamps
    end

    add_index :goals, [:goalsetter_id]
  end


  def self.down
    drop_table :goals
  end
end
