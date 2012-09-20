class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :goal_id
      t.boolean :is_treasury
      t.decimal :balance, :precision => 8, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
