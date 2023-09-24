class CreateUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :units do |t|
      t.references :game
      t.references :country
      t.timestamps
    end
  end
end
