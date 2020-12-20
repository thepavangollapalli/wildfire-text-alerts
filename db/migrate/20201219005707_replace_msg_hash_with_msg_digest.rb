class ReplaceMsgHashWithMsgDigest < ActiveRecord::Migration[6.0]
  def change
    change_table :wildfire_text_alerts do |t|
      t.string :msg_digest
      t.remove :msg_hash
    end
  end
end
