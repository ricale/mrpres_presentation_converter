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

ActiveRecord::Schema.define(version: 20140415140538) do

  create_table "broadcasts", force: true do |t|
    t.integer   "user_id",         null: false
    t.integer   "presentation_id", null: false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "converted_presentations", force: true do |t|
    t.integer   "presentation_id",             null: false
    t.string    "file_name",                   null: false
    t.integer   "total_pages",     default: 0
    t.integer   "status"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "presentations", force: true do |t|
    t.integer   "user_id",     null: false
    t.string    "title",       null: false
    t.text      "description"
    t.integer   "status"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "users", force: true do |t|
    t.string    "email",         null: false
    t.string    "password",      null: false
    t.string    "name",          null: false
    t.string    "access_token"
    t.string    "refresh_token"
    t.string    "expire_in"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "users", ["email"], name: "id_UNIQUE", unique: true, using: :btree

end
