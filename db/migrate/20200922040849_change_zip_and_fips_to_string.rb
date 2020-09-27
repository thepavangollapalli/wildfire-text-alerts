class ChangeZipAndFipsToString < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :zip, :string
    change_column :wildfires, :fips, :string
  end
end
