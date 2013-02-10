class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :payee_id
      t.integer :recipient_id
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0

      t.timestamps
    end
  end
end
