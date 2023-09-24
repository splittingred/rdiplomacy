class AddCoastToUnitPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_positions, :coast, :string
  end
end
