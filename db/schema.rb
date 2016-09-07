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

ActiveRecord::Schema.define(version: 20160202080427) do

  create_table "game_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "winner_id"
  end

  create_table "players", force: :cascade do |t|
    t.text     "code",            default: "class Strategy\n  def initialize\n    @my_unit = Unit.new\n    @info    = World.new\n  end\n\n  def move\n    # Write logic here\n  end\nend"
    t.boolean  "is_in_game",      default: true
    t.datetime "created_at",                                                                                                                                                               null: false
    t.datetime "updated_at",                                                                                                                                                               null: false
    t.integer  "user_id"
    t.integer  "game_session_id"
  end

  add_index "players", ["game_session_id"], name: "index_players_on_game_session_id"
  add_index "players", ["user_id"], name: "index_players_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "password_digest"
    t.string   "remember_token"
    t.integer  "wins_count",      default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
