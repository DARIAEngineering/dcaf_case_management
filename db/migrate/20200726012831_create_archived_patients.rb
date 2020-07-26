class CreateArchivedPatients < ActiveRecord::Migration[6.0]
  def change
    create_table :archived_patients do |t|
      t.string :identifier
      t.boolean :has_alt_contact
      t.integer :age_range
      t.integer :voicemail_preference
      t.integer :line
      t.string :language
      t.date :initial_call_date
      t.boolean :urgent_flag
      t.integer :last_menstrual_period_weeks
      t.integer :last_menstrual_period_days
      t.string :city
      t.string :state
      t.string :county
      t.string :race_ethnicity
      t.string :employment_status
      t.string :insurance
      t.string :income
      t.integer :notes_count
      t.boolean :has_special_circumstances
      t.string :referred_by
      t.boolean :referred_to_clinic
      t.date :appointment_date
      t.integer :procedure_cost
      t.integer :patient_contribution
      t.integer :naf_pledge
      t.integer :fund_pledge
      t.timestamp :fund_pledged_at
      t.boolean :pledge_sent
      t.boolean :resolved_without_fund
      t.timestamp :pledge_generated_at
      t.boolean :textable

      t.timestamps
    end
  end
end
