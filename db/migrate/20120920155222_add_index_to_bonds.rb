class AddIndexToBonds < ActiveRecord::Migration
  def self.up
    add_index :bonds, [:creditor_id, :debtor_id], :unique => true, :name => "creditor_debtor"
  end
  
  def self.down
    remove_index :bonds, "creditor_debtor"
  end
end
