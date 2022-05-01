# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2021_12_19_044530) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "archived_patients", force: :cascade do |t|
    t.string "identifier"
    t.string "age_range", default: "not_specified"
    t.boolean "has_alt_contact"
    t.string "voicemail_preference", default: "not_specified"
    t.string "line_legacy"
    t.string "language"
    t.date "initial_call_date"
    t.boolean "urgent_flag"
    t.integer "last_menstrual_period_weeks"
    t.integer "last_menstrual_period_days"
    t.string "city"
    t.string "state"
    t.string "county"
    t.string "race_ethnicity"
    t.string "employment_status"
    t.string "insurance"
    t.string "income"
    t.integer "notes_count"
    t.boolean "has_special_circumstances"
    t.string "referred_by"
    t.boolean "referred_to_clinic"
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
    t.bigint "clinic_id"
    t.bigint "pledge_generated_by_id"
    t.bigint "pledge_sent_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.bigint "line_id", null: false
    t.index ["clinic_id"], name: "index_archived_patients_on_clinic_id"
    t.index ["fund_id"], name: "index_archived_patients_on_fund_id"
    t.index ["line_id"], name: "index_archived_patients_on_line_id"
    t.index ["line_legacy"], name: "index_archived_patients_on_line_legacy"
    t.index ["pledge_generated_by_id"], name: "index_archived_patients_on_pledge_generated_by_id"
    t.index ["pledge_sent_by_id"], name: "index_archived_patients_on_pledge_sent_by_id"
  end

  create_table "call_list_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "patient_id", null: false
    t.string "line_legacy"
    t.integer "order_key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.bigint "line_id", null: false
    t.index ["fund_id"], name: "index_call_list_entries_on_fund_id"
    t.index ["line_id"], name: "index_call_list_entries_on_line_id"
    t.index ["line_legacy"], name: "index_call_list_entries_on_line_legacy"
    t.index ["patient_id"], name: "index_call_list_entries_on_patient_id"
    t.index ["user_id"], name: "index_call_list_entries_on_user_id"
  end

  create_table "calls", force: :cascade do |t|
    t.integer "status", null: false
    t.string "can_call_type", null: false
    t.bigint "can_call_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.index ["can_call_type", "can_call_id"], name: "index_calls_on_can_call_type_and_can_call_id"
    t.index ["fund_id"], name: "index_calls_on_fund_id"
  end

  create_table "clinics", force: :cascade do |t|
    t.string "name", null: false
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "fax"
    t.boolean "active", default: true, null: false
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
    t.bigint "fund_id"
    t.index ["fund_id"], name: "index_clinics_on_fund_id"
  end

  create_table "configs", force: :cascade do |t|
    t.integer "config_key", null: false
    t.jsonb "config_value", default: {"options"=>[]}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.index ["config_key", "fund_id"], name: "index_configs_on_config_key_and_fund_id", unique: true
    t.index ["fund_id"], name: "index_configs_on_fund_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "cm_name"
    t.integer "event_type"
    t.string "line_legacy"
    t.string "patient_name"
    t.string "patient_id"
    t.integer "pledge_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.bigint "line_id", null: false
    t.index ["created_at"], name: "index_events_on_created_at"
    t.index ["fund_id"], name: "index_events_on_fund_id"
    t.index ["line_id"], name: "index_events_on_line_id"
    t.index ["line_legacy"], name: "index_events_on_line_legacy"
  end

  create_table "external_pledges", force: :cascade do |t|
    t.string "source", null: false
    t.integer "amount"
    t.boolean "active"
    t.string "can_pledge_type", null: false
    t.bigint "can_pledge_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.index ["can_pledge_type", "can_pledge_id"], name: "index_external_pledges_on_can_pledge_type_and_can_pledge_id"
    t.index ["fund_id"], name: "index_external_pledges_on_fund_id"
  end

  create_table "fulfillments", force: :cascade do |t|
    t.boolean "fulfilled", default: false, null: false
    t.date "procedure_date"
    t.integer "gestation_at_procedure"
    t.integer "fund_payout"
    t.string "check_number"
    t.date "date_of_check"
    t.boolean "audited"
    t.string "can_fulfill_type", null: false
    t.bigint "can_fulfill_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.index ["audited"], name: "index_fulfillments_on_audited"
    t.index ["can_fulfill_type", "can_fulfill_id"], name: "index_fulfillments_on_can_fulfill_type_and_can_fulfill_id"
    t.index ["fulfilled"], name: "index_fulfillments_on_fulfilled"
    t.index ["fund_id"], name: "index_fulfillments_on_fund_id"
  end

  create_table "funds", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.string "domain"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "full_name", comment: "Full name of the fund. e.g. DC Abortion Fund"
    t.string "site_domain", comment: "URL of the fund's public-facing website. e.g. www.dcabortionfund.org"
    t.string "phone", comment: "Contact number for the abortion fund, usually the hotline"
    t.string "pledge_generation_config", comment: "Optional config of which pledge generation configset to use. If null, pledge generation is shut off"
  end

  create_table "lines", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "fund_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["fund_id"], name: "index_lines_on_fund_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "full_text", null: false
    t.bigint "patient_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.index ["fund_id"], name: "index_notes_on_fund_id"
    t.index ["patient_id"], name: "index_notes_on_patient_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "name", null: false
    t.string "primary_phone", null: false
    t.string "other_contact"
    t.string "other_phone"
    t.string "other_contact_relationship"
    t.string "identifier"
    t.string "voicemail_preference", default: "not_specified"
    t.string "line_legacy"
    t.string "language"
    t.string "pronouns"
    t.date "initial_call_date", null: false
    t.boolean "urgent_flag"
    t.integer "last_menstrual_period_weeks"
    t.integer "last_menstrual_period_days"
    t.integer "age"
    t.string "city"
    t.string "state"
    t.string "county"
    t.string "zipcode"
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
    t.bigint "clinic_id"
    t.bigint "pledge_generated_by_id"
    t.bigint "pledge_sent_by_id"
    t.bigint "last_edited_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.bigint "line_id", null: false
    t.index ["clinic_id"], name: "index_patients_on_clinic_id"
    t.index ["fund_id"], name: "index_patients_on_fund_id"
    t.index ["identifier"], name: "index_patients_on_identifier"
    t.index ["last_edited_by_id"], name: "index_patients_on_last_edited_by_id"
    t.index ["line_id"], name: "index_patients_on_line_id"
    t.index ["line_legacy"], name: "index_patients_on_line_legacy"
    t.index ["name"], name: "index_patients_on_name"
    t.index ["other_contact"], name: "index_patients_on_other_contact"
    t.index ["other_phone"], name: "index_patients_on_other_phone"
    t.index ["pledge_generated_by_id"], name: "index_patients_on_pledge_generated_by_id"
    t.index ["pledge_sent"], name: "index_patients_on_pledge_sent"
    t.index ["pledge_sent_by_id"], name: "index_patients_on_pledge_sent_by_id"
    t.index ["primary_phone", "fund_id"], name: "index_patients_on_primary_phone_and_fund_id", unique: true
    t.index ["urgent_flag"], name: "index_patients_on_urgent_flag"
  end

  create_table "practical_supports", force: :cascade do |t|
    t.string "support_type", null: false
    t.boolean "confirmed"
    t.string "source", null: false
    t.string "can_support_type"
    t.bigint "can_support_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "fund_id"
    t.decimal "amount", precision: 8, scale: 2
    t.index ["can_support_type", "can_support_id"], name: "index_practical_supports_on_can_support_type_and_can_support_id"
    t.index ["fund_id"], name: "index_practical_supports_on_fund_id"
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
    t.string "name", null: false
    t.string "line"
    t.integer "role", default: 0, null: false
    t.boolean "disabled_by_fund", default: false
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
    t.bigint "fund_id"
    t.index ["email", "fund_id"], name: "index_users_on_email_and_fund_id", unique: true
    t.index ["fund_id"], name: "index_users_on_fund_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type"
    t.string "{:null=>false}"
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.json "object_changes"
    t.datetime "created_at"
    t.bigint "fund_id"
    t.index ["fund_id"], name: "index_versions_on_fund_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "archived_patients", "clinics"
  add_foreign_key "archived_patients", "funds"
  add_foreign_key "archived_patients", "lines"
  add_foreign_key "archived_patients", "users", column: "pledge_generated_by_id"
  add_foreign_key "archived_patients", "users", column: "pledge_sent_by_id"
  add_foreign_key "call_list_entries", "funds"
  add_foreign_key "call_list_entries", "lines"
  add_foreign_key "call_list_entries", "patients"
  add_foreign_key "call_list_entries", "users"
  add_foreign_key "calls", "funds"
  add_foreign_key "clinics", "funds"
  add_foreign_key "configs", "funds"
  add_foreign_key "events", "funds"
  add_foreign_key "events", "lines"
  add_foreign_key "external_pledges", "funds"
  add_foreign_key "fulfillments", "funds"
  add_foreign_key "lines", "funds"
  add_foreign_key "notes", "funds"
  add_foreign_key "patients", "clinics"
  add_foreign_key "patients", "funds"
  add_foreign_key "patients", "lines"
  add_foreign_key "patients", "users", column: "last_edited_by_id"
  add_foreign_key "patients", "users", column: "pledge_generated_by_id"
  add_foreign_key "patients", "users", column: "pledge_sent_by_id"
  add_foreign_key "practical_supports", "funds"
  add_foreign_key "users", "funds"
  add_foreign_key "versions", "funds"
end
