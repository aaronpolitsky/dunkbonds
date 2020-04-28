class GoalsController < ApplicationController
  before_action :load_account, :except => [:index, :new, :create]

  before_action :authenticate_user!, :except => [:index, :show]
  
  before_action :can_create_goal, :except  => [:index, :show]

  # GET /goals
  # GET /goals.xml
  def index
    @goals = Goal.all

    @followed_goals = current_or_guest_user.followed_goals
    @unfollowed_goals = @goals - @followed_goals
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @goals }
    end
  end

  # GET /goals/1
  # GET /goals/1.xml
  def show
    @goal = Goal.find(params[:id])
    @posts = @goal.posts.all
    @latest_posts = @goal.posts.order("published_at desc")[0...5]
    @sticky_post = @goal.posts.order(:published_at).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @goal }
    end
  end

  # GET /goals/new
  # GET /goals/new.xml
  def new
    @goal = Goal.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @goal }
    end
  end

  # GET /goals/1/edit
  def edit
    @goal = Goal.find(params[:id])
  end

  # POST /goals
  # POST /goals.xml
  def create
    @goal = Goal.new(params[:goal])
    @goal.goalsetter = current_user

    respond_to do |format|
      if @goal.save
        format.html { redirect_to(@goal, :notice => 'Goal was successfully created.') }
        format.xml  { render :xml => @goal, :status => :created, :location => @goal }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @goal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /goals/1
  # PUT /goals/1.xml
  def update
    @goal = Goal.find(params[:id])

    respond_to do |format|
      if @goal.update_attributes(params[:goal])
        format.html { redirect_to(@goal, :notice => 'Goal was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @goal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /goals/1
  # DELETE /goals/1.xml
  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy

    respond_to do |format|
      format.html { redirect_to(goals_url) }
      format.xml  { head :ok }
    end
  end

  private

  def load_account
    @account = current_or_guest_user.accounts.find_by_goal_id(params[:id])
  end

  def can_create_goal
    unless current_or_guest_user.email == "aaron.politsky@gmail.com" || current_user.is_admin?
      flash[:warning] = "nice try."
      redirect_to goals_path  
    end
  end
end




