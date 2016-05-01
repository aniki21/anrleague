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

ActiveRecord::Schema.define(version: 20160501223336) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "factions", force: :cascade do |t|
    t.string   "display_name"
    t.string   "icon_style"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "side"
  end

  add_index "factions", ["side"], name: "index_factions_on_side", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer  "league_id"
    t.integer  "season_id"
    t.integer  "runner_player_id"
    t.integer  "runner_identity_id"
    t.integer  "runner_agenda_points"
    t.integer  "corp_player_id"
    t.integer  "corp_identity_id"
    t.integer  "corp_agenda_points"
    t.integer  "result_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "winning_player_id"
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "faction_id"
    t.string   "display_name"
    t.string   "nrdb_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "short_name"
  end

  create_table "liga_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "liga_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ligas", force: :cascade do |t|
    t.string   "display_name"
    t.integer  "owner_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "location_type"
    t.string   "online_location"
    t.decimal  "latitude",             default: 0.0
    t.decimal  "longitude",            default: 0.0
    t.text     "description_markdown"
    t.text     "description_html"
    t.string   "offline_location"
  end

  add_index "ligas", ["location_type"], name: "index_ligas_on_location_type", using: :btree

  create_table "results", force: :cascade do |t|
    t.string   "display_name"
    t.string   "winning_side"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "results", ["winning_side"], name: "index_results_on_winning_side", using: :btree

  create_table "seasons", force: :cascade do |t|
    t.integer  "league_id"
    t.string   "display_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "aasm_state"
    t.text     "league_table"
  end

  add_index "seasons", ["aasm_state"], name: "index_seasons_on_aasm_state", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                                           null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "display_name"
    t.string   "jinteki_username"
    t.boolean  "admin",                           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

end
