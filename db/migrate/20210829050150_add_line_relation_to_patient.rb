class AddLineRelationToPatient < ActiveRecord::Migration[6.1]
  def change
    remove_column :patients, :line
    add_reference :patients, :line, foreign_key: true
  end
end
