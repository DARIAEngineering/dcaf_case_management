class AllowMultiPrimaryPhoneOnPatient < ActiveRecord::Migration[6.1]
  def change
    remove_index :patients, :primary_phone, unique: true
    add_index :patients, [:primary_phone, :fund_id], unique: true
  end
end
