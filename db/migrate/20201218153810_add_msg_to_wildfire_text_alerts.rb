class AddMsgToWildfireTextAlerts < ActiveRecord::Migration[6.0]
  def change
    change_table :wildfire_text_alerts do |t|
      t.text :msg
    end
  end
end
