class AddAssistanceTerritory < ActiveRecord::Migration[7.0]
  def change
    add_column :moves, :assistance_territory_id, :bigint, index: true
    change_column :moves, :from_territory_id, :bigint
    change_column :moves, :to_territory_id, :bigint
    add_index :moves, :from_territory_id
    add_index :moves, :to_territory_id

    add_column :orders, :assistance_territory_id, :bigint, index: true
    change_column :orders, :from_territory_id, :bigint, index: true
    change_column :orders, :to_territory_id, :bigint, index: true
    add_index :orders, :from_territory_id
    add_index :orders, :to_territory_id
  end
end
