class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      t.string :name, null: false
      t.string :primary_phone, null: false
      t.string :other_contact
      t.string :other_phone
      t.string :other_contact_relationship
      t.string :identifier

      t.string :voicemail_preference, default: 'not_specified'
      t.string :line, null: false

      t.integer :language
      t.integer :pronouns
      t.date :initial_call_date, null: false
      t.boolean :urgent_flag
      t.integer :last_menstrual_period_weeks
      t.integer :last_menstrual_period_days

      t.integer :age
      t.string :city
      t.string :state
      t.string :county
      t.integer :zipcode
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

      t.datetime :appointment_date
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

      t.references :clinic, foreign_key: true
      t.references :pledge_generated_by, foreign_key: { to_table: :users }
      t.references :pledge_sent_by, foreign_key: { to_table: :users }
      t.references :last_edited_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :patients, :primary_phone, unique: true
    add_index :patients, :other_phone
    add_index :patients, :other_contact
    add_index :patients, :name
    add_index :patients, :line
    add_index :patients, :urgent_flag
    add_index :patients, :identifier
    add_index :patients, :pledge_sent 
  end
end
