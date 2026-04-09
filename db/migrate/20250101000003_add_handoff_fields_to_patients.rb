class AddHandoffFieldsToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :handed_off_at, :datetime
    add_column :patients, :handed_off_from_id, :bigint
    add_column :patients, :handed_off_to_id, :bigint
    add_column :patients, :handoff_note, :text
  end
end
