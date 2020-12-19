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

ActiveRecord::Schema.define(version: 2020_12_16_054649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

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

end
