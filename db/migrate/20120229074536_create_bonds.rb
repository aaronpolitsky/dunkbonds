class CreateBonds < ActiveRecord::Migration
  def self.up
    create_table :bonds do |t|
      t.integer :account_id
      t.decimal :maturity_value, :precision => 8, :scale => 2
      t.datetime :maturity_date
      t.datetime :coupon_period
      t.decimal :price, :precision => 8, :scale => 2
      t.integer :updated_by
      t.boolean :is_deleted, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :bonds
  end
end
