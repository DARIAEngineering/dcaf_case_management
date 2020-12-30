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

ActiveRecord::Schema.define(version: 2020_12_30_075535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "call_lists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "patient_id", null: false
    t.integer "order_key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["patient_id"], name: "index_call_lists_on_patient_id"
    t.index ["user_id"], name: "index_call_lists_on_user_id"
  end

  create_table "calls", force: :cascade do |t|
    t.integer "status", null: false
    t.string "can_call_type", null: false
    t.bigint "can_call_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["can_call_type", "can_call_id"], name: "index_calls_on_can_call_type_and_can_call_id"
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
    t.string "mongo_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "configs", force: :cascade do |t|
    t.integer "config_key", null: false
    t.jsonb "config_value", default: {"options"=>[]}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["config_key"], name: "index_configs_on_config_key"
  end

  create_table "events", force: :cascade do |t|
    t.string "cm_name"
    t.integer "event_type"
    t.string "line"
    t.string "patient_name"
    t.string "patient_id"
    t.integer "pledge_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_events_on_created_at"
    t.index ["line"], name: "index_events_on_line"
  end

  create_table "external_pledges", force: :cascade do |t|
    t.string "source", null: false
    t.integer "amount"
    t.boolean "active"
    t.string "can_pledge_type", null: false
    t.bigint "can_pledge_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["can_pledge_type", "can_pledge_id"], name: "index_external_pledges_on_can_pledge_type_and_can_pledge_id"
  end

  create_table "fulfillments", force: :cascade do |t|
    t.boolean "fulfilled", default: false, null: false
    t.date "procedure_date"
    t.integer "gestation_at_procedure"
    t.integer "fund_payout"
    t.string "check_number"
    t.string "date_of_check"
    t.boolean "audited"
    t.string "can_fulfill_type", null: false
    t.bigint "can_fulfill_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["audited"], name: "index_fulfillments_on_audited"
    t.index ["can_fulfill_type", "can_fulfill_id"], name: "index_fulfillments_on_can_fulfill_type_and_can_fulfill_id"
    t.index ["fulfilled"], name: "index_fulfillments_on_fulfilled"
  end

  create_table "notes", force: :cascade do |t|
    t.string "full_text", null: false
    t.bigint "patient_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.string "line", null: false
    t.integer "language"
    t.integer "pronouns"
    t.date "initial_call_date", null: false
    t.boolean "urgent_flag"
    t.integer "last_menstrual_period_weeks"
    t.integer "last_menstrual_period_days"
    t.integer "age"
    t.string "city"
    t.string "state"
    t.string "county"
    t.integer "zipcode"
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
    t.datetime "appointment_date"
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
    t.index ["clinic_id"], name: "index_patients_on_clinic_id"
    t.index ["identifier"], name: "index_patients_on_identifier"
    t.index ["last_edited_by_id"], name: "index_patients_on_last_edited_by_id"
    t.index ["line"], name: "index_patients_on_line"
    t.index ["name"], name: "index_patients_on_name"
    t.index ["other_contact"], name: "index_patients_on_other_contact"
    t.index ["other_phone"], name: "index_patients_on_other_phone"
    t.index ["pledge_generated_by_id"], name: "index_patients_on_pledge_generated_by_id"
    t.index ["pledge_sent"], name: "index_patients_on_pledge_sent"
    t.index ["pledge_sent_by_id"], name: "index_patients_on_pledge_sent_by_id"
    t.index ["primary_phone"], name: "index_patients_on_primary_phone", unique: true
    t.index ["urgent_flag"], name: "index_patients_on_urgent_flag"
  end

  create_table "practical_supports", force: :cascade do |t|
    t.string "support_type"
    t.boolean "confirmed"
    t.string "source"
    t.string "can_support_type"
    t.bigint "can_support_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["can_support_type", "can_support_id"], name: "index_practical_supports_on_can_support_type_and_can_support_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "line"
    t.integer "role", default: 0, null: false
    t.boolean "disabled_by_fund", default: false
    t.string "mongo_id"
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

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.json "object_changes"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "call_lists", "patients"
  add_foreign_key "call_lists", "users"
  add_foreign_key "patients", "clinics"
  add_foreign_key "patients", "users", column: "last_edited_by_id"
  add_foreign_key "patients", "users", column: "pledge_generated_by_id"
  add_foreign_key "patients", "users", column: "pledge_sent_by_id"
end
