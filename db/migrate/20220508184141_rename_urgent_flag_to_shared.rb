class RenameUrgentFlagToShared < ActiveRecord::Migration[6.1]
  def change
    rename_column :patients, :urgent_flag, :shared_flag
    rename_column :archived_patients, :urgent_flag, :shared_flag

    Patient.reset_column_information
  end
end
