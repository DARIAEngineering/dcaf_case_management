class AddUltrasoundCostToPatient < ActiveRecord::Migration[7.1]
  def change
    add_column :patients, :ultrasound_cost, :integer
  end
end
