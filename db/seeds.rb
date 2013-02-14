# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

user1 = Factory.create(:user)
user2 = Factory.create(:asdf)
user3 = Factory.create(:fdsa)

goal1 = Factory.create(:goal_w_blog, :goalsetter_id => user1.id)
goal2 = Factory.create(:certain_date_goal, :goalsetter_id => user2.id)

Goal.all.each do |g|
	g.get_sticky_posts
	g.update_from_feed
end

user1.follow_goal goal2

user2.follow_goal goal1

user3.follow_goal goal1
user3.follow_goal goal2
