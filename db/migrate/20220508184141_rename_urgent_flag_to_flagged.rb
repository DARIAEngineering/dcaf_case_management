class RenameUrgentFlagToFlagged < ActiveRecord::Migration[6.1]
  def change
    rename_column :patients, :urgent_flag, :flagged
    rename_column :archived_patients, :urgent_flag, :flagged

    Patient.reset_column_information
  end
end
