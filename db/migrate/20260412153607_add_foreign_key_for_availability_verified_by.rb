class AddForeignKeyForAvailabilityVerifiedBy < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :clinics, :users, column: :availability_verified_by_id
  end
end
