class AdjustVariantFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :variants, :start_year
    remove_column :variants, :start_season
    remove_column :variants, :start_order
    remove_column :variants, :abbreviation

    rename_column :territories, :abbreviation, :abbr
    rename_column :countries, :abbreviation, :abbr
  end
end
