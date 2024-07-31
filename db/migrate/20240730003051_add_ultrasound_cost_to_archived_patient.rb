class AddUltrasoundCostToArchivedPatient < ActiveRecord::Migration[7.1]
  def change
    add_column :archived_patients, :ultrasound_cost, :integer
  end
end
