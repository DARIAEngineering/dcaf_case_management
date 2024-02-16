class AddMarkedCompleteToPatient < ActiveRecord::Migration[7.0]
  def change
    add_column :patients, :marked_complete, :boolean
  end
end
