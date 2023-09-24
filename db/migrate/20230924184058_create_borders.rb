class CreateBorders < ActiveRecord::Migration[7.0]
  def change
    create_table :borders do |t|
      t.references :variant, null: false
      t.integer :from_territory_id, null: false, index: true
      t.integer :to_territory_id, null: false, index: true
      t.boolean :sea_passable, null: false, default: false
      t.boolean :land_passable, null: false, default: false
      t.timestamps
    end
  end
end
