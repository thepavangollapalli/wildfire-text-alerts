class AddMsgHashToWildfireTextAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :wildfire_text_alerts, :msg_hash, :bigint
  end
end
