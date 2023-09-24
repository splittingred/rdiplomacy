class AdjustFields < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_positions, :territory_id, :integer, null: false, index: true, after: :turn_id
    remove_column :unit_positions, :territory
    remove_column :unit_positions, :coast

    remove_column :orders, :from_territory_id
    remove_column :orders, :to_territory_id
    add_column :orders, :from_territory_id, :integer, null: false, index: true, after: :unit_position_id
    add_column :orders, :to_territory_id, :integer, null: false, index: true, after: :from_territory_id

    remove_column :moves, :from_territory_id
    remove_column :moves, :to_territory_id
    add_column :moves, :from_territory_id, :integer, null: false, index: true, after: :unit_position_id
    add_column :moves, :to_territory_id, :integer, null: false, index: true, after: :from_territory_id
  end
end
