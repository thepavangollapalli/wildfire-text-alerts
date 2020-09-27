class AddObjectIdToWildfires < ActiveRecord::Migration[6.0]
  def change
    add_column :wildfires, :object_id, :integer
  end
end
