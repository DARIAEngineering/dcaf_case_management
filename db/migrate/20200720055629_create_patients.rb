class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      # Searchable info
      t.string :name, index: true
      t.string :primary_phone, index: { unique: true }
      t.string :other_contact
      t.string :other_phone, index: true
      t.string :other_contact_relationship
      t.string :identifier, index: true

      # Contact-related info
      t.integer :voicemail_preference
      t.integer :line, index: true
      t.string :language
      t.date :initial_call_date
      t.boolean :urgent_flag, index: true

      t.integer :last_menstrual_period_weeks
      t.integer :last_menstrual_period_days

      # Program analysis related or NAF eligibility related info
      t.integer :age
      t.string :city
      t.string :state
      t.string :county
      t.string :race_ethnicity
      t.string :employment_status
      t.integer :household_size_children
      t.integer :household_size_adults
      t.string :insurance
      t.string :income
      t.string :special_circumstances, array: true, default: []
      t.string :referred_by
      t.boolean :referred_to_clinic
      t.boolean :completed_ultrasound

      # Status and pledge related fields
      t.date :appointment_date
      t.integer :procedure_cost
      t.integer :patient_contribution
      t.integer :naf_pledge
      t.integer :fund_pledge
      t.datetime :fund_pledged_at
      t.boolean :pledge_sent
      t.boolean :resolved_without_fund
      t.datetime :pledge_generated_at
      t.datetime :pledge_sent_at
      t.boolean :textable

      t.timestamps
    end
  end
end
