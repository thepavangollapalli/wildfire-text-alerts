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

ActiveRecord::Schema.define(version: 2020_09_22_040849) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.text "phone"
    t.string "zip"
    t.boolean "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "wildfire_text_alerts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "wildfire_id"
    t.datetime "text_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "wildfires", force: :cascade do |t|
    t.string "incident_name"
    t.float "initial_latitude"
    t.float "initial_longitude"
    t.datetime "discovered_at"
    t.float "calculated_acres"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "object_id"
    t.string "fips"
  end

end
