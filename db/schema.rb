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

ActiveRecord::Schema.define(:version => 20121204024937) do

  create_table "accounts", :force => true do |t|
    t.integer  "goal_id"
    t.boolean  "is_treasury"
    t.decimal  "balance",     :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bonds", :force => true do |t|
    t.integer  "creditor_id"
    t.integer  "debtor_id"
    t.integer  "qty"
    t.integer  "goal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bonds", ["creditor_id", "debtor_id", "goal_id"], :name => "creditor_debtor_goal", :unique => true

  create_table "carts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "goals", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string   "period"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "blog_url"
    t.string   "blog_service_provider"
  end

  create_table "line_items", :force => true do |t|
    t.integer  "account_id"
    t.string   "status",                                        :default => "new"
    t.string   "type_of"
    t.decimal  "max_bid_min_ask", :precision => 8, :scale => 2
    t.integer  "goal_id"
    t.integer  "cart_id"
    t.integer  "order_id"
    t.decimal  "price",           :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "account_id"
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
    t.boolean  "is_visible",   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
