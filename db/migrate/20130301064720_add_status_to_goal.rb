class AddStatusToGoal < ActiveRecord::Migration[6.0]
  def change
    add_column :goals, :status, :string, :default => "incomplete"
  end
end
