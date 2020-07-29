class CreateClinics < ActiveRecord::Migration[6.0]
  def change
    create_table :clinics do |t|
      t.string :name, null: false
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.string :fax
      t.boolean :active, null: false, default: true
      t.boolean :accepts_naf
      t.boolean :accepts_medicaid
      t.integer :gestational_limit
      t.numeric :coordinates, array: true

      # Cost fields
      t.integer :costs_5wks
      t.integer :costs_6wks
      t.integer :costs_7wks
      t.integer :costs_8wks
      t.integer :costs_9wks
      t.integer :costs_10wks
      t.integer :costs_11wks
      t.integer :costs_12wks
      t.integer :costs_13wks
      t.integer :costs_14wks
      t.integer :costs_15wks
      t.integer :costs_16wks
      t.integer :costs_17wks
      t.integer :costs_18wks
      t.integer :costs_19wks
      t.integer :costs_20wks
      t.integer :costs_21wks
      t.integer :costs_22wks
      t.integer :costs_23wks
      t.integer :costs_24wks
      t.integer :costs_25wks
      t.integer :costs_26wks
      t.integer :costs_27wks
      t.integer :costs_28wks
      t.integer :costs_29wks
      t.integer :costs_30wks

      t.timestamps
    end
  end
end
