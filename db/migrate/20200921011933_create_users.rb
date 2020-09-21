class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.text :phone
      t.string :zip
      t.boolean :active

      t.timestamps
    end
  end
end
