class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :game
      t.references :country
      t.references :player
      t.timestamps
    end
  end
end
