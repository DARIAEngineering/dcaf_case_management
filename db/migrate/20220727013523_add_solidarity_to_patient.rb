class AddSolidarityToPatient < ActiveRecord::Migration[7.0]
  def change
    add_column :patients, :solidarity, :boolean
    add_column :archived_patients, :solidarity, :boolean
  end
end
