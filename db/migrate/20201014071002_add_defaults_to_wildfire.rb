class AddDefaultsToWildfire < ActiveRecord::Migration[6.0]
  def change
    change_column :wildfires, :calculated_acres, :float, :default => 0.0
    change_column :wildfires, :percent_contained, :float, :default => 0.0
  end
end
