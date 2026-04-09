class AddAvailabilityFieldsToClinics < ActiveRecord::Migration[8.1]
  def change
    add_column :clinics, :availability_verified_at, :datetime
    add_column :clinics, :availability_verified_by_id, :bigint
    add_column :clinics, :availability_notes, :text
  end
end
