class AddAvailabilityFieldsToClinics < ActiveRecord::Migration[8.0]
  def change
    add_column :clinics, :availability_verified_at, :datetime
    add_column :clinics, :availability_verified_by_id, :integer
    add_column :clinics, :availability_notes, :text
  end
end
