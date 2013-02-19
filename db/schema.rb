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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130219073941) do

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "balance",     :precision => 8, :scale => 2, :default => 0.0
    t.boolean  "is_escrow",                                 :default => false
    t.boolean  "is_treasury",                               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "goal_id"
  end

  add_index "accounts", ["user_id", "goal_id"], :name => "user_goal", :unique => true

  create_table "bonds", :force => true do |t|
    t.integer  "creditor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "debtor_id"
    t.integer  "qty",         :default => 0
  end

  add_index "bonds", ["creditor_id", "debtor_id"], :name => "creditor_debtor", :unique => true

  create_table "goals", :force => true do |t|
    t.integer  "goalsetter_id"
    t.string   "type_of"
    t.text     "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "is_completed",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "blog_url"
    t.string   "title"
    t.string   "blog_service_provider"
  end

  add_index "goals", ["goalsetter_id"], :name => "index_goals_on_goalsetter_id"

  create_table "orders", :force => true do |t|
    t.integer  "account_id"
    t.string   "type_of"
    t.string   "status"
    t.decimal  "max_bid",    :precision => 8, :scale => 2
    t.decimal  "min_ask",    :precision => 8, :scale => 2
    t.integer  "updated_by"
    t.boolean  "is_deleted",                               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "goal_id"
    t.integer  "bond_id"
    t.decimal  "price",      :precision => 8, :scale => 2
    t.integer  "match_id"
  end

  create_table "payments", :force => true do |t|
    t.integer  "recipient_id"
    t.integer  "payer_id"
    t.decimal  "amount",       :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "goal_id"
    t.string   "title"
    t.text     "content"
    t.string   "url"
    t.datetime "published_at"
    t.string   "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["guid"], :name => "index_posts_on_guid"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "is_admin",               :default => false
    t.boolean  "is_guest",               :default => false
    t.boolean  "gets_email",             :default => true
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
