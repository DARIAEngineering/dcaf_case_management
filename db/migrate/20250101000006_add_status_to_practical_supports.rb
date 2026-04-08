class AddStatusToPracticalSupports < ActiveRecord::Migration[8.0]
  def change
    add_column :practical_supports, :status, :integer, default: 0, null: false
    add_column :practical_supports, :status_updated_at, :datetime
    add_column :practical_supports, :confirmed_at, :datetime
  end
end
