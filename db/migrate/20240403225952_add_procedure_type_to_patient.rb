class AddProcedureTypeToPatient < ActiveRecord::Migration[7.1]
  def change
    add_column :patients, :procedure_type, :string
    add_column :archived_patients, :procedure_type, :string
  end
end
