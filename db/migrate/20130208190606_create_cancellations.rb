class CreateCancellations < ActiveRecord::Migration
  def change
    create_table :cancellations do |t|
      t.integer :line_item_id

      t.timestamps
    end
  end
end
