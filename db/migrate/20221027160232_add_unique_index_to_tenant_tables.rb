class AddUniqueIndexToTenantTables < ActiveRecord::Migration[7.0]
  def change
    add_index :clinics, [:name, :fund_id], unique: true
    add_index :lines, [:name, :fund_id], unique: true
    add_index :call_list_entries, [:patient_id, :user_id, :fund_id], unique: true
  end
end
