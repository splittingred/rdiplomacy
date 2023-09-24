class AddUnitPosition < ActiveRecord::Migration[7.0]
  def change
    create_table :unit_positions do |t|
      t.references :unit, null: false
      t.string :territory, null: false
      t.integer :turn_id, null: false, default: 1
      t.timestamps
    end
  end
end
