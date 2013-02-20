class AddPeriodToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :period, :string

    Goal.reset_column_information
    g = Goal.first
    g.period = "1 month"
    g.save!
  end
end
