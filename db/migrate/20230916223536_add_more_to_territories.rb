class AddMoreToTerritories < ActiveRecord::Migration[7.0]
  def change
    add_column :territories, :name, :string, index: true
    add_column :territories, :abbreviation, :string, index: true
    add_column :territories, :geographical_type, :string, default: 'land', index: true
    add_column :territories, :supply_center, :boolean, default: false, index: true
    add_column :territories, :map_x, :integer, default: false
    add_column :territories, :map_y, :integer, default: false
  end
end
