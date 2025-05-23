class OneBigMigration < ActiveRecord::Migration[6.0]
	def up
		# create_table "accounts", :force => true do |t|
		# 	t.integer  "user_id"
		# 	t.decimal  "balance",     :precision => 8, :scale => 2, :default => 0.0
		# 	t.boolean  "is_escrow",                                 :default => false
		# 	t.boolean  "is_treasury",                               :default => false
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# 	t.integer  "goal_id"
		# end

		# add_index "accounts", ["user_id", "goal_id"], :name => "user_goal", :unique => true

		# create_table "bonds", :force => true do |t|
		# 	t.integer  "creditor_id"
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# 	t.integer  "debtor_id"
		# 	t.integer  "qty",         :default => 0
		# end

		# add_index "bonds", ["creditor_id", "debtor_id"], :name => "creditor_debtor", :unique => true

		# create_table "cancellations", :force => true do |t|
		# 	t.integer  "line_item_id"
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# end

		# create_table "carts", :force => true do |t|
		# 	t.integer  "user_id"
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# end

		# create_table "goals", :force => true do |t|
		# 	t.integer  "goalsetter_id"
		# 	t.string   "type_of"
		# 	t.text     "description"
		# 	t.datetime "starts_at"
		# 	t.datetime "ends_at"
		# 	t.boolean  "is_completed",          :default => false
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# 	t.string   "blog_url"
		# 	t.string   "title"
		# 	t.string   "blog_service_provider"
		# 	t.string   "period"
		# end

		# add_index "goals", ["goalsetter_id"], :name => "index_goals_on_goalsetter_id"

		# create_table "line_items", :force => true do |t|
		# 	t.string   "status",                        :default => "new"
		# 	t.string   "type_of"
		# 	t.decimal  "max_bid_min_ask", :precision => 8, :scale => 2
		# 	t.integer  "account_id"
		# 	t.integer  "cart_id"
		# 	t.integer  "order_id"
		# 	t.integer  "qty"
		# 	t.integer  "parent_id"
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# end

		# create_table "orders", :force => true do |t|
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# 	t.integer  "user_id"
		# end

		# create_table "payments", :force => true do |t|
		# 	t.integer  "recipient_id"
		# 	t.integer  "payer_id"
		# 	t.decimal  "amount",       :precision => 8, :scale => 2, :default => 0.0
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# end

		# create_table "posts", :force => true do |t|
		# 	t.integer  "goal_id"
		# 	t.string   "title"
		# 	t.text     "content"
		# 	t.string   "url"
		# 	t.datetime "published_at"
		# 	t.string   "guid"
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# end

		# add_index "posts", ["guid"], :name => "index_posts_on_guid"

		# create_table "trades", :force => true do |t|
		# 	t.integer  "bid_id"
		# 	t.integer  "ask_id"
		# 	t.integer  "qty"
		# 	t.decimal  "price",      :precision => 8, :scale => 2
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# end

		# add_index "trades", ["bid_id", "ask_id"], :name => "bid_ask"

		# create_table "users", :force => true do |t|
		# 	t.string   "email",                  :default => "",    :null => false
		# 	t.string   "encrypted_password",     :default => "",    :null => false
		# 	t.string   "reset_password_token"
		# 	t.datetime "reset_password_sent_at"
		# 	t.datetime "remember_created_at"
		# 	t.integer  "sign_in_count",          :default => 0
		# 	t.datetime "current_sign_in_at"
		# 	t.datetime "last_sign_in_at"
		# 	t.string   "current_sign_in_ip"
		# 	t.string   "last_sign_in_ip"
		# 	t.string   "confirmation_token"
		# 	t.datetime "confirmed_at"
		# 	t.datetime "confirmation_sent_at"
		# 	t.string   "unconfirmed_email"
		# 	t.integer  "failed_attempts",        :default => 0
		# 	t.string   "unlock_token"
		# 	t.datetime "locked_at"
		# 	t.string   "authentication_token"
		# 	t.datetime "created_at"
		# 	t.datetime "updated_at"
		# 	t.string   "name"
		# 	t.boolean  "is_admin",               :default => false
		# 	t.boolean  "is_guest",               :default => false
		# 	t.boolean  "gets_email",             :default => true
		# end

		# add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
		# add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
		# add_index "users", ["email"], :name => "index_users_on_email", :unique => true
		# add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
		# add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

	end

	def down

	end
end
