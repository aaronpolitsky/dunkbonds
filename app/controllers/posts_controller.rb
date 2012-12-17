class PostsController < ApplicationController

  before_filter :load_goal

  # GET /posts
  # GET /posts.xml
  def index
    @posts = @goal.posts.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = @goal.posts.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = @goal.posts.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = @goal.posts.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = @goal.posts.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to [@goal, @post], :notice => 'Post was successfully created.' }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = @goal.posts.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to [@goal, @post], :notice => 'Post was successfully updated.' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = @goal.posts.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(goal_posts_url) }
      format.xml  { head :ok }
    end
  end

  private
  
  def load_goal
    @goal = Goal.find(params[:goal_id]) unless params[:goal_id].nil?
  end

end
