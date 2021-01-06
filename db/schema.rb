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

ActiveRecord::Schema.define(version: 20210106233719) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "scheduled_end_time"
    t.boolean "next_day", default: false
    t.string "business_process_content"
    t.integer "overtime_application_target_superior_id"
    t.string "overtime_application_status"
    t.boolean "change", default: false
    t.integer "attendance_change_application_target_superior_id"
    t.string "attendance_change_application_status"
    t.datetime "started_at_before_change"
    t.datetime "finished_at_before_change"
    t.datetime "started_at_after_change"
    t.datetime "finished_at_after_change"
    t.boolean "change_for_attendance_change", default: false
    t.integer "affiliation_manager_approval_application_target_superior_id"
    t.boolean "change_for_affiliation_manager_approval_application", default: false
    t.string "affiliation_manager_approval_application_status"
    t.datetime "finished_at_log"
    t.datetime "started_at_log"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "base_name"
    t.string "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "base_number"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.datetime "basic_time", default: "2021-01-03 23:00:00"
    t.datetime "work_time", default: "2021-01-03 22:30:00"
    t.integer "employee_number"
    t.string "uid"
    t.datetime "basic_work_time", default: "2021-01-03 23:00:00"
    t.datetime "designated_work_start_time", default: "2021-01-03 23:30:00"
    t.datetime "designated_work_end_time", default: "2021-01-04 08:30:00"
    t.boolean "superior", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
