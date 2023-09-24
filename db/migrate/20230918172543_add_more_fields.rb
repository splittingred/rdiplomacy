class AddMoreFields < ActiveRecord::Migration[7.0]
  def change
    add_reference :moves, :unit_position, null: false
    add_reference :orders, :unit_position, null: false
    add_column :turns, :year, :integer, null: false
    add_column :turns, :season, :string, null: false
    add_column :units, :unit_type, :string, null: false
    add_column :variants, :abbr, :string, null: false
  end
end
