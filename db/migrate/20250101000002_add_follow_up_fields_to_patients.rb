class AddFollowUpFieldsToPatients < ActiveRecord::Migration[8.0]
  def change
    add_column :patients, :follow_up_date, :date
    add_column :patients, :follow_up_reason, :string, limit: 200
    add_index :patients, :follow_up_date
  end
end
