class CreateWildfires < ActiveRecord::Migration[6.0]
  def change
    create_table :wildfires do |t|
      t.string :incident_name
      t.float :initial_latitude
      t.float :initial_longitude
      t.datetime :discovered_at
      t.float :calculated_acres

      t.timestamps
    end
  end
end
