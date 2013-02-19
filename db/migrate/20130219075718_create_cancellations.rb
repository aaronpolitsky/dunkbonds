class CreateCancellations < ActiveRecord::Migration
  def self.up
  	create_table :cancellations do |t|
      t.integer :line_item_id

      t.timestamps
    end
  end

  def self.down
  	drop_table :cancellations
  end
end
