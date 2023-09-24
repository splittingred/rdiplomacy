class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.references :game, null: false
      t.references :current_player, null: false
      t.timestamps
    end
  end
end
