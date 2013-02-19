class ChangeBonds < ActiveRecord::Migration
  def up
  	change_table(:bonds) do |t|
  		t.rename  :account_id, :creditor_id
  		t.integer :debtor_id
   		t.integer :qty, :default => 0
  		t.remove :maturity_value, :maturity_date, :coupon_period, :price, :updated_by, :is_deleted, :goal_id
  	end

  	add_index :bonds, [:creditor_id, :debtor_id], :unique => true, :name => "creditor_debtor"

  	Bond.reset_column_information

 		#remove treasury's unsold bonds from escrow by finding from order
 		Order.where(:status => "pending",
 		            :account_id => 2,
 		            :type_of => "ask").each do |o|
			b = Bond.find(o.bond_id)
			b.destroy!
			o.destroy!
		end

		#reassign the rest as linking creditor and debtor				
		Account.all.each do |a|
			bonds = a.bonds
			qty = bonds.count
			a.bonds.create!(:debtor_id => 2, :qty => qty)
		end

  end

  def down
		remove_index :bonds, :name => "creditor_debtor"

  	change_table(:bonds) do |t|
  		t.remove :debtor_id, :qty
  		t.rename :creditor_id, :account_id
  		t.integer :goal_id
  		t.boolean :is_deleted
  		t.integer :updated_by
  		t.decimal :price, :precision => 8, :scale => 2
  		t.datetime :coupon_period
  		t.datetime :maturity_date
  		t.decimal :maturity_value, :precision => 8, :scale => 2
  	end
  end
end
