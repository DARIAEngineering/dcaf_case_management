class RemoveLineLegacy < ActiveRecord::Migration[7.0]
  def change
    remove_column :archived_patients, :line_legacy, :string
    remove_column :call_list_entries, :line_legacy, :string
    remove_column :events, :line_legacy, :string
    remove_column :patients, :line_legacy, :string
  end
end
