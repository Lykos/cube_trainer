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

ActiveRecord::Schema.define(version: 2020_04_01_075552) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "download_states", force: :cascade do |t|
    t.text "model"
    t.datetime "downloaded_at"
    t.string "timestamps"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["model"], name: "index_download_states_on_model", unique: true
  end

  create_table "inputs", force: :cascade do |t|
    t.text "old_mode"
    t.text "input_representation"
    t.string "timestamps"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "old_user_id"
    t.string "hostname", null: false
    t.bigint "mode_id", null: false
    t.index ["mode_id"], name: "index_inputs_on_mode_id"
    t.index ["old_user_id"], name: "index_inputs_on_old_user_id"
  end

  create_table "modes", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.boolean "known"
    t.string "mode_type"
    t.string "show_input_mode"
    t.string "buffer"
    t.float "goal_badness"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "cube_size"
    t.index ["user_id", "name"], name: "index_modes_on_user_id_and_name", unique: true
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
    t.index ["created_at"], name: "index_results_on_created_at"
    t.index ["input_id"], name: "index_results_on_input_id", unique: true
    t.index ["old_hostname", "old_user_id", "created_at"], name: "index_results_on_old_hostname_and_old_user_id_and_created_at", unique: true
    t.index ["old_mode", "old_user_id"], name: "index_results_on_old_mode_and_old_user_id"
    t.index ["old_user_id"], name: "index_results_on_old_user_id"
    t.index ["uploaded_at"], name: "index_results_on_uploaded_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "admin", default: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "inputs", "modes"
  add_foreign_key "results", "inputs"
end
