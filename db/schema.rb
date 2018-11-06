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

ActiveRecord::Schema.define(version: 2018_11_05_184736) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "stored_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stored_files_tags", id: false, force: :cascade do |t|
    t.uuid "stored_file_id", null: false
    t.bigint "tag_id", null: false
    t.index ["stored_file_id"], name: "index_stored_files_tags_on_stored_file_id"
    t.index ["tag_id"], name: "index_stored_files_tags_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 100
  end

  add_foreign_key "stored_files_tags", "stored_files"
  add_foreign_key "stored_files_tags", "tags"
end
