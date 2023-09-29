class ConvertBordersToStr < ActiveRecord::Migration[7.0]
  def change
    change_column :borders, :from_territory_id, :string
    rename_column :borders, :from_territory_id, :from_territory_abbr
    change_column :borders, :to_territory_id, :string
    rename_column :borders, :to_territory_id, :to_territory_abbr
  end
end
