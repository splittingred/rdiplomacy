class CreateMoves < ActiveRecord::Migration[7.0]
  def change
    create_table :moves do |t|
      t.references :game
      t.references :country
      t.references :player
      t.timestamps
    end
  end
end
