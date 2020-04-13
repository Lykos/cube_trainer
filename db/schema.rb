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

ActiveRecord::Schema.define(version: 2020_04_13_075113) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievement_grants", force: :cascade do |t|
    t.bigint "achievement_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["achievement_id"], name: "index_achievement_grants_on_achievement_id", unique: true
    t.index ["user_id", "achievement_id"], name: "index_achievement_grants_on_user_id_and_achievement_id", unique: true
    t.index ["user_id"], name: "index_achievement_grants_on_user_id", unique: true
  end

  create_table "achievements", force: :cascade do |t|
    t.string "name", null: false
    t.string "achievement_type", null: false
    t.integer "param"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["achievement_type"], name: "index_achievements_on_achievement_type"
    t.index ["name"], name: "index_achievements_on_name", unique: true
  end

  create_table "download_states", force: :cascade do |t|
    t.text "model", null: false
    t.datetime "downloaded_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["model"], name: "index_download_states_on_model", unique: true
  end

  create_table "inputs", force: :cascade do |t|
    t.text "old_mode"
    t.text "input_representation", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "old_user_id"
    t.string "hostname", null: false
    t.bigint "mode_id", null: false
    t.index ["mode_id"], name: "index_inputs_on_mode_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "body"
    t.boolean "read", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "modes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.boolean "known", default: false, null: false
    t.string "mode_type", null: false
    t.string "show_input_mode", null: false
    t.string "buffer"
    t.float "goal_badness"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "cube_size"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "message"
    t.boolean "read"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "results", force: :cascade do |t|
    t.text "old_mode"
    t.float "time_s", null: false
    t.text "old_input_representation"
    t.integer "failed_attempts", default: 0, null: false
    t.text "word"
    t.boolean "success", default: true, null: false
    t.integer "num_hints", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "old_hostname"
    t.datetime "uploaded_at", precision: 6
    t.integer "old_user_id"
    t.bigint "input_id", null: false
    t.index ["input_id"], name: "index_results_on_input_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "admin", default: false, null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "achievement_grants", "achievements"
  add_foreign_key "achievement_grants", "users"
  add_foreign_key "inputs", "modes"
  add_foreign_key "messages", "users"
  add_foreign_key "modes", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "results", "inputs"
end
