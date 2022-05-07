class ChangeUrgentToFlagged < ActiveRecord::Migration[6.1]
  def change
    rename_column :patients, :urgent_flag, :flagged
    rename_column :archived_patients, :urgent_flag, :flagged
  end
end
  