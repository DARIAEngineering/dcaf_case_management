class AddEmailForPledgesToClinics < ActiveRecord::Migration[7.0]
  def change
    add_column :clinics, :email_for_pledges, :string
  end
end
