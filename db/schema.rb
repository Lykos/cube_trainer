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

ActiveRecord::Schema.define(version: 2020_03_25_185817) do

  create_table "cube_trainer_training_download_states", force: :cascade do |t|
    t.text "model"
    t.datetime "downloaded_at"
    t.string "timestamps"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["model"], name: "index_cube_trainer_training_download_states_on_model", unique: true
  end

  create_table "cube_trainer_training_inputs", force: :cascade do |t|
    t.text "mode"
    t.text "input_representation"
    t.string "timestamps"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cube_trainer_training_results", force: :cascade do |t|
    t.text "mode", null: false
    t.float "time_s", null: false
    t.text "input_representation", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.text "word"
    t.boolean "success", default: true, null: false
    t.integer "num_hints", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "hostname", null: false
    t.datetime "uploaded_at", precision: 6
    t.index ["created_at"], name: "index_cube_trainer_training_results_on_created_at"
    t.index ["hostname", "created_at"], name: "index_cube_trainer_training_results_on_hostname_and_created_at", unique: true
    t.index ["mode"], name: "index_cube_trainer_training_results_on_mode"
    t.index ["uploaded_at"], name: "index_cube_trainer_training_results_on_uploaded_at"
  end

end
