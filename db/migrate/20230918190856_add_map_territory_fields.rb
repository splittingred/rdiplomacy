class AddMapTerritoryFields < ActiveRecord::Migration[7.0]
  def change
    add_column :territories, :parent_territory_id, :bigint
    add_column :territories, :coast, :boolean
    add_column :territories, :unit_x, :float
    add_column :territories, :unit_y, :float
    add_column :territories, :unit_dislodged_x, :float
    add_column :territories, :unit_dislodged_y, :float

    add_column :variants, :abbreviation, :string
    add_column :variants, :description, :string
    add_column :variants, :start_year, :integer, default: 1901
    add_column :variants, :start_season, :string, default: 'SPRING'
    add_column :variants, :start_order, :string, default: 'MOVE'

    add_column :turns, :current, :boolean, default: false
    add_column :unit_positions, :dislodged, :boolean, default: false

    remove_column :territories, :map_x
    remove_column :territories, :map_y
  end
end
