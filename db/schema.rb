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

ActiveRecord::Schema.define(version: 2022_01_01_100340) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievement_grants", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "achievement", null: false
    t.index ["user_id", "achievement"], name: "index_achievement_grants_on_user_id_and_achievement", unique: true
    t.index ["user_id"], name: "index_achievement_grants_on_user_id"
  end

  create_table "alg_overrides", force: :cascade do |t|
    t.bigint "training_session_id", null: false
    t.string "casee", null: false
    t.string "alg", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["training_session_id"], name: "index_alg_overrides_on_training_session_id"
  end

  create_table "alg_sets", force: :cascade do |t|
    t.bigint "alg_spreadsheet_id", null: false
    t.string "sheet_title", null: false
    t.string "training_session_type"
    t.string "buffer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "case_set"
    t.index ["alg_spreadsheet_id"], name: "index_alg_sets_on_alg_spreadsheet_id"
  end

  create_table "alg_spreadsheets", force: :cascade do |t|
    t.string "owner", null: false
    t.string "spreadsheet_id", null: false
  end

  create_table "algs", force: :cascade do |t|
    t.bigint "alg_set_id", null: false
    t.string "casee", null: false
    t.text "alg", null: false
    t.boolean "is_fixed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alg_set_id"], name: "index_algs_on_alg_set_id"
  end

  create_table "color_schemes", force: :cascade do |t|
    t.string "color_u", null: false
    t.string "color_f", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_color_schemes_on_user_id", unique: true
  end

  create_table "letter_scheme_mappings", force: :cascade do |t|
    t.integer "letter_scheme_id", null: false
    t.string "part", null: false
    t.string "letter", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["letter_scheme_id", "part"], name: "index_letter_scheme_mappings_on_letter_scheme_id_and_part", unique: true
    t.index ["letter_scheme_id"], name: "index_letter_scheme_mappings_on_letter_scheme_id"
  end

  create_table "letter_schemes", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_letter_schemes_on_user_id", unique: true
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

  create_table "results", force: :cascade do |t|
    t.float "time_s", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.text "word"
    t.boolean "success", default: true, null: false
    t.integer "num_hints", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "uploaded_at", precision: 6
    t.string "casee", null: false
    t.integer "training_session_id", null: false
    t.index ["casee"], name: "index_results_on_casee"
  end

  create_table "stats", force: :cascade do |t|
    t.bigint "training_session_id", null: false
    t.string "stat_type", null: false
    t.integer "index", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["training_session_id", "index"], name: "index_stats_on_training_session_id_and_index", unique: true
    t.index ["training_session_id", "stat_type"], name: "index_stats_on_training_session_id_and_stat_type", unique: true
    t.index ["training_session_id"], name: "index_stats_on_training_session_id"
  end

  create_table "training_session_usages", force: :cascade do |t|
    t.bigint "training_session_id", null: false
    t.bigint "used_training_session_id", null: false
    t.index ["training_session_id"], name: "index_training_session_usages_on_training_session_id"
    t.index ["used_training_session_id"], name: "index_training_session_usages_on_used_training_session_id"
  end

  create_table "training_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.boolean "known", default: false, null: false
    t.string "training_session_type", null: false
    t.string "show_input_mode", null: false
    t.float "goal_badness"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "cube_size"
    t.string "first_parity_part"
    t.string "second_parity_part"
    t.float "memo_time_s"
    t.string "buffer"
    t.integer "alg_set_id"
    t.index ["user_id", "name"], name: "index_training_sessions_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_training_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "admin", default: false, null: false
    t.string "email"
    t.boolean "admin_confirmed", default: false
    t.boolean "email_confirmed", default: false
    t.string "confirm_token"
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.json "tokens"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "achievement_grants", "users"
  add_foreign_key "alg_overrides", "training_sessions"
  add_foreign_key "alg_sets", "alg_spreadsheets"
  add_foreign_key "algs", "alg_sets"
  add_foreign_key "color_schemes", "users"
  add_foreign_key "letter_scheme_mappings", "letter_schemes"
  add_foreign_key "letter_schemes", "users"
  add_foreign_key "messages", "users"
  add_foreign_key "results", "training_sessions"
  add_foreign_key "stats", "training_sessions"
  add_foreign_key "training_session_usages", "training_sessions"
  add_foreign_key "training_session_usages", "training_sessions", column: "used_training_session_id"
  add_foreign_key "training_sessions", "alg_sets"
  add_foreign_key "training_sessions", "users"
end
