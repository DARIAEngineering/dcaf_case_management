# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_22_055255) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calls", force: :cascade do |t|
    t.string "status"
    t.bigint "can_call_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["can_call_id"], name: "index_calls_on_can_call_id"
  end

  create_table "clinics", force: :cascade do |t|
    t.string "name"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "fax"
    t.boolean "active"
    t.boolean "accepts_naf"
    t.boolean "accepts_medicaid"
    t.integer "gestational_limit"
    t.decimal "coordinates", array: true
    t.integer "costs_5wks"
    t.integer "costs_6wks"
    t.integer "costs_7wks"
    t.integer "costs_8wks"
    t.integer "costs_9wks"
    t.integer "costs_10wks"
    t.integer "costs_11wks"
    t.integer "costs_12wks"
    t.integer "costs_13wks"
    t.integer "costs_14wks"
    t.integer "costs_15wks"
    t.integer "costs_16wks"
    t.integer "costs_17wks"
    t.integer "costs_18wks"
    t.integer "costs_19wks"
    t.integer "costs_20wks"
    t.integer "costs_21wks"
    t.integer "costs_22wks"
    t.integer "costs_23wks"
    t.integer "costs_24wks"
    t.integer "costs_25wks"
    t.integer "costs_26wks"
    t.integer "costs_27wks"
    t.integer "costs_28wks"
    t.integer "costs_29wks"
    t.integer "costs_30wks"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "cm_name"
    t.integer "event_type"
    t.integer "line"
    t.string "patient_name"
    t.string "patient_id"
    t.integer "pledge_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_events_on_created_at"
  end

  create_table "patients", force: :cascade do |t|
    t.string "name"
    t.string "primary_phone"
    t.string "other_contact"
    t.string "other_phone"
    t.string "other_contact_relationship"
    t.string "identifier"
    t.integer "voicemail_preference"
    t.integer "line"
    t.string "language"
    t.date "initial_call_date"
    t.boolean "urgent_flag"
    t.integer "last_menstrual_period_weeks"
    t.integer "last_menstrual_period_days"
    t.integer "age"
    t.string "city"
    t.string "state"
    t.string "county"
    t.string "race_ethnicity"
    t.string "employment_status"
    t.integer "household_size_children"
    t.integer "household_size_adults"
    t.string "insurance"
    t.string "income"
    t.string "special_circumstances", default: [], array: true
    t.string "referred_by"
    t.boolean "referred_to_clinic"
    t.boolean "completed_ultrasound"
    t.date "appointment_date"
    t.integer "procedure_cost"
    t.integer "patient_contribution"
    t.integer "naf_pledge"
    t.integer "fund_pledge"
    t.datetime "fund_pledged_at"
    t.boolean "pledge_sent"
    t.boolean "resolved_without_fund"
    t.datetime "pledge_generated_at"
    t.datetime "pledge_sent_at"
    t.boolean "textable"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_patients_on_identifier"
    t.index ["line"], name: "index_patients_on_line"
    t.index ["name"], name: "index_patients_on_name"
    t.index ["other_phone"], name: "index_patients_on_other_phone"
    t.index ["primary_phone"], name: "index_patients_on_primary_phone", unique: true
    t.index ["urgent_flag"], name: "index_patients_on_urgent_flag"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "line"
    t.boolean "disabled_by_fund"
    t.string "call_order", array: true
    t.integer "role", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
