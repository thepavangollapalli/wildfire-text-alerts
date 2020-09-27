class AddFipsToWildfire < ActiveRecord::Migration[6.0]
  def change
    add_column :wildfires, :fips, :integer
  end
end
