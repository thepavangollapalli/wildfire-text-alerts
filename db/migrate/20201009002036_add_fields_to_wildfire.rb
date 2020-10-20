class AddFieldsToWildfire < ActiveRecord::Migration[6.0]
  def change
    add_column :wildfires, :archived_on, :datetime
    add_column :wildfires, :percent_contained, :float
    add_column :wildfires, :stale, :boolean
  end
end
