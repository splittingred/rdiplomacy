class CreateTerritories < ActiveRecord::Migration[7.0]
  def change
    create_table :territories do |t|
      t.references :variant, null: false
      t.timestamps
    end
  end
end
