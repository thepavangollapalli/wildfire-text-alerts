class CreateWildfireTextAlerts < ActiveRecord::Migration[6.0]
  def change
    create_table :wildfire_text_alerts do |t|
      t.integer :user_id
      t.integer :wildfire_id
      t.datetime :text_sent_at

      t.timestamps
    end
  end
end
