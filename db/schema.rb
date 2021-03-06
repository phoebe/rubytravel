# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100505141647) do

  create_table "participations", :force => true do |t|
    t.string   "name"
    t.integer  "trip_id"
    t.integer  "user_id"
    t.integer  "profile_id"
    t.integer  "radius"
    t.date     "travel_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles_tags", :force => true do |t|
    t.integer  "profile_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name",           :null => false
    t.string   "uri"
    t.string   "code"
    t.string   "code2"
    t.string   "code3"
    t.integer  "creator_id"
    t.integer  "parent_id"
    t.integer  "children_count"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "trips", :force => true do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.string   "description"
    t.date     "departure_date"
    t.integer  "duration"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.datetime "last_login"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.string   "state"
    t.string   "country_code"
    t.date     "birthday"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.string   "remember_token",     :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
