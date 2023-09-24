class AddOtherFields < ActiveRecord::Migration[7.0]
  def change
    add_column :moves, :turn_id, :bigint
    add_column :moves, :move_type, :string
    add_column :moves, :to_territory_id, :bigint
    add_column :moves, :from_territory_id, :bigint
    add_column :moves, :convoyed, :boolean
    add_column :moves, :successful, :boolean
    add_column :moves, :dislodged, :boolean
    add_reference :moves, :order, null: false

    add_column :orders, :turn_id, :bigint
    add_column :orders, :to_territory_id, :bigint
    add_column :orders, :from_territory_id, :bigint
    add_column :orders, :convoyed, :boolean
  end
end
