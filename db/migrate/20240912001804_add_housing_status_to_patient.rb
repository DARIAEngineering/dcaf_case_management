class AddHousingStatusToPatient < ActiveRecord::Migration[7.1]
  def change
    add_column :patients, :housing_status, :string
  end
end
