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

ActiveRecord::Schema.define(version: 2022_05_12_040821) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "url", null: false
    t.string "name", null: false
    t.string "type"
    t.integer "width"
    t.integer "height"
    t.integer "crc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.text "file", null: false
    t.text "fields", null: false
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "print_form_code"
    t.index ["code", "active"], name: "index_order_types_on_code_and_active"
    t.index ["code", "created_at"], name: "index_order_types_on_code_and_created_at", unique: true
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "order_type_id", null: false
    t.integer "user_id"
    t.string "code", null: false
    t.string "ext_code"
    t.string "bp_id"
    t.string "bp_state"
    t.integer "state", default: 0
    t.datetime "done_at"
    t.boolean "archived", default: false
    t.jsonb "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "estimated_exec_date"
    t.index ["code"], name: "index_orders_on_code"
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "order_type_id", null: false
    t.json "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_type_id"], name: "index_profiles_on_order_type_id"
    t.index ["user_id", "order_type_id"], name: "index_profiles_on_user_id_and_order_type_id", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "sequences", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "prefix", null: false
    t.integer "start", default: 1
    t.index ["name"], name: "index_sequences_on_name"
  end

  create_table "users", id: :serial, force: :cascade do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "role"
    t.string "middle_name"
    t.string "last_name", null: false
    t.string "company"
    t.string "department"
    t.string "api_token"
    t.string "password_salt"
    t.boolean "external", default: false, null: false
    t.boolean "blocked", default: false, null: false
    t.string "provider"
    t.string "uid"
    t.string "directory", default: "internal", null: false
    t.index ["api_token"], name: "index_users_on_api_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "profiles", "order_types"
  add_foreign_key "profiles", "users"
end
