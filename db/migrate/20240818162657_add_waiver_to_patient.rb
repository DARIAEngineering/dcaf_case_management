class AddWaiverToPatient < ActiveRecord::Migration[7.1]
  def change
    add_column :patients, :practical_support_waiver, :boolean, comment: 'Optional practical support services waiver, for funds that use them'
    add_column :archived_patients, :practical_support_waiver, :boolean, comment: 'Optional practical support services waiver, for funds that use them'
  end
end
