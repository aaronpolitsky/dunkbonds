class PostsController < ApplicationController

  before_filter :load_stuff

  # GET /posts
  # GET /posts.xml
  def index
    @posts = @goal.posts.order("published_at desc").paginate(:page => params[:page], :per_page => 5)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = @goal.posts.find(params[:id])
    @title = @post.title

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  private
  
  def load_stuff
    @goal = Goal.find(params[:goal_id]) unless params[:goal_id].nil?
    @account = current_or_guest_user.accounts.find_by_goal_id(@goal.id) 
  end

end
