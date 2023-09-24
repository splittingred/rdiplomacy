class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string :name
      t.references :variant, null: false
      t.timestamps
    end
  end
end
