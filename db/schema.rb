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

ActiveRecord::Schema[8.0].define(version: 2026_03_23_144513) do
  create_table "games", force: :cascade do |t|
    t.integer "state"
    t.string "code"
    t.string "host"
    t.integer "rounds", default: 2
    t.integer "time_per_turn", default: 120000
    t.integer "mad_score", default: 0
    t.integer "glad_score", default: 0
    t.text "players"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "word_theme", default: "default"
  end

  create_table "sub_turns", force: :cascade do |t|
    t.integer "score", default: 0
    t.string "easy_word"
    t.string "hard_word"
    t.integer "state"
    t.integer "skip_type"
    t.integer "turn_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turn_id"], name: "index_sub_turns_on_turn_id"
  end

  create_table "turns", force: :cascade do |t|
    t.integer "state"
    t.string "player_id"
    t.string "judge_id"
    t.integer "total_score", default: 0
    t.integer "round", default: 1
    t.integer "easy_count", default: 0
    t.integer "hard_count", default: 0
    t.integer "game_id"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_turns_on_game_id"
  end

  create_table "turns_words", id: false, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "turn_id"
    t.integer "word_id"
    t.index ["turn_id"], name: "index_turns_words_on_turn_id"
    t.index ["word_id"], name: "index_turns_words_on_word_id"
  end

  create_table "words", force: :cascade do |t|
    t.string "word"
    t.integer "difficulty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme"
  end
end
