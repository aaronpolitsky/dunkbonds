class HomeController < ApplicationController
  def index
  	@dunkgoal = Goal.find 1
  	@latest_posts = @dunkgoal.posts.order("published_at desc")[0...5]
  	@othergoals = Goal.where("id != ?", @dunkgoal.id)
  end

end
