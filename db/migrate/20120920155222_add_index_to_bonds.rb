class AddIndexToBonds < ActiveRecord::Migration
  def change
    add_index :bonds, [:creditor_id, :debtor_id, :goal_id], :unique => true
  end
end
