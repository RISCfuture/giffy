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

ActiveRecord::Schema.define(version: 20170815011501) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorization_requests", id: :serial, force: :cascade do |t|
    t.integer "authorization_id"
    t.string "code", limit: 128, null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_id"], name: "index_authorization_requests_on_authorization_id"
  end

  create_table "authorizations", id: :serial, force: :cascade do |t|
    t.string "access_token", limit: 128, null: false
    t.string "scope", limit: 128, null: false
    t.string "team_name", limit: 128
    t.string "team_id", limit: 20, null: false
    t.string "incoming_webhook_url", limit: 255
    t.string "incoming_webhook_channel", limit: 128
    t.string "incoming_webhook_config_url", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_authorizations_on_team_id", unique: true
    t.index ["team_name"], name: "index_authorizations_on_team_name"
  end

  create_table "gif_results", id: :serial, force: :cascade do |t|
    t.integer "authorization_id", null: false
    t.string "channel_id", limit: 64, null: false
    t.string "user_id", limit: 64, null: false
    t.string "user_name", limit: 64, null: false
    t.string "query", null: false
    t.string "image_url", null: false
    t.string "response_url", null: false
    t.boolean "noped", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_id"], name: "index_gif_results_on_authorization_id"
  end

  add_foreign_key "authorization_requests", "authorizations", on_delete: :cascade
  add_foreign_key "gif_results", "authorizations", on_delete: :cascade
end
