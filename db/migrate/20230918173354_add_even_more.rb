class AddEvenMore < ActiveRecord::Migration[7.0]
  def up
    change_column :moves, :to_territory_id, :string
    change_column :moves, :from_territory_id, :string
    change_column :orders, :to_territory_id, :string
    change_column :orders, :from_territory_id, :string
    add_column :orders, :move_type, :string
  end

  def down
    change_column :moves, :to_territory_id, :integer
    change_column :moves, :from_territory_id, :integer
    change_column :orders, :to_territory_id, :integer
    change_column :orders, :from_territory_id, :integer
    remove_column :orders, :move_type
  end
end
