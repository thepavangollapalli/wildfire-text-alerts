class AddZipToWildfireTextAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :wildfire_text_alerts, :zip, :string
  end
end
