class AddSolidarityLeadToPatient < ActiveRecord::Migration[7.0]
  def change
    add_column :patients, :solidarity_lead, :string
    add_column :archived_patients, :solidarity_lead, :string
  end
end
