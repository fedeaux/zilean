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

ActiveRecord::Schema.define(version: 20160918230802) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "color"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ancestry"
    t.string   "path_names"
    t.index ["user_id"], name: "index_activities_on_user_id", using: :btree
  end

  create_table "log_entries", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "observations"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["activity_id"], name: "index_log_entries_on_activity_id", using: :btree
    t.index ["user_id"], name: "index_log_entries_on_user_id", using: :btree
  end

  create_table "report_activities", force: :cascade do |t|
    t.integer "report_id"
    t.integer "activity_id"
    t.index ["activity_id"], name: "index_report_activities_on_activity_id", using: :btree
    t.index ["report_id"], name: "index_report_activities_on_report_id", using: :btree
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "trackers",   default: [],              array: true
    t.text     "weekdays",   default: [],              array: true
    t.datetime "start"
    t.datetime "finish"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["user_id"], name: "index_reports_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "timezone"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "activities", "users"
  add_foreign_key "log_entries", "activities"
  add_foreign_key "log_entries", "users"
  add_foreign_key "report_activities", "activities"
  add_foreign_key "report_activities", "reports"
  add_foreign_key "reports", "users"
end
