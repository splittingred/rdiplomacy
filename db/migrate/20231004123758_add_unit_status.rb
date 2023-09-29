class AddUnitStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :status, :string, null: false, default: 'active', index: true
  end
end
