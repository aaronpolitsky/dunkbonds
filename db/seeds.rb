# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

user = Factory.create(:user)
aaron = Factory.create(:aaron)
dad = Factory.create(:dad)
mateo = Factory.create(:mateo)

dunk = Factory.create(:aarondunks, :goalsetter_id => aaron.id)
boston = Factory.create(:boston, :goalsetter_id => mateo.id)
par = Factory.create(:par, :goalsetter_id => dad.id)

Goal.all.each do |g|
	g.get_sticky_posts
	g.update_from_feed
end

user.follow_goal dunk

aaron.follow_goal boston

dad.follow_goal dunk


