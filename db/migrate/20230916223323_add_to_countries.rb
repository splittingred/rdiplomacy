class AddToCountries < ActiveRecord::Migration[7.0]
  def change
    add_column :countries, :name, :string, null: false, index: true
    add_column :countries, :abbreviation, :string
    add_column :countries, :color, :string
    add_column :countries, :starting_supply_centers, :integer, null: false, default: 1
  end
end
