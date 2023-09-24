class AddTurnFields < ActiveRecord::Migration[7.0]
  def change
    add_column :turns, :status, :string
    add_column :turns, :adjucated, :boolean, default: false
    add_column :turns, :adjucated_at, :datetime
    add_column :turns, :deadline_at, :datetime
    add_column :turns, :started_at, :datetime
    add_column :turns, :finished_at, :datetime
  end
end
