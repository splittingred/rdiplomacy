class AddMapToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :map_abbr, :string, after: :variant_id, index: true
  end
end
