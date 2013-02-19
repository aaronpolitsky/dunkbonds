class AddPeriodToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :period, :string
  end
end
