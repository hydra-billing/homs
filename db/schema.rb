# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180303130859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "order_types", force: :cascade do |t|
    t.string   "code",                            null: false
    t.text     "file",                            null: false
    t.text     "fields",                          null: false
    t.boolean  "active",          default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "name",                            null: false
    t.string   "print_form_code"
  end

  add_index "order_types", ["code", "active"], name: "index_order_types_on_code_and_active", using: :btree
  add_index "order_types", ["code", "created_at"], name: "index_order_types_on_code_and_created_at", unique: true, using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "order_type_id",                       null: false
    t.integer  "user_id"
    t.string   "code",                                null: false
    t.string   "ext_code"
    t.string   "bp_id"
    t.string   "bp_state"
    t.integer  "state",               default: 0
    t.datetime "done_at"
    t.boolean  "archived",            default: false
    t.jsonb    "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "estimated_exec_date"
  end

  add_index "orders", ["code"], name: "index_orders_on_code", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.integer  "order_type_id", null: false
    t.json     "data",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "profiles", ["order_type_id"], name: "index_profiles_on_order_type_id", using: :btree
  add_index "profiles", ["user_id", "order_type_id"], name: "index_profiles_on_user_id_and_order_type_id", unique: true, using: :btree
  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "sequences", force: :cascade do |t|
    t.string  "name",               null: false
    t.string  "prefix",             null: false
    t.integer "start",  default: 1
  end

  add_index "sequences", ["name"], name: "index_sequences_on_name", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                                   null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "role"
    t.string   "middle_name"
    t.string   "last_name",                              null: false
    t.string   "company"
    t.string   "department"
    t.string   "api_token"
    t.string   "password_salt"
    t.boolean  "external",               default: false, null: false
    t.boolean  "blocked",                default: false, null: false
  end

  add_index "users", ["api_token"], name: "index_users_on_api_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "profiles", "order_types"
  add_foreign_key "profiles", "users"
end
