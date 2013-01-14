class AccountsController < ApplicationController
  # GET /goals/1/accounts
  # GET /goals/1/accounts.xml

  before_filter :authenticate_user!, :except => [:index, :new]

  before_filter :load_goal
  before_filter :correct_user

#  before_filter :is_admin?, :only => [:index, :edit, :update]

  def index
    @accounts = @goal.accounts.where('user_id') #is non-nil

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = @goal.accounts.find(params[:id])
    @line_items = @account.line_items
    @order_line_items = @line_items.group_by { |li| li.order.id }

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = @goal.accounts.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = @goal.accounts.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    new_follow = current_user.follow_goal(@goal)
    @account = current_user.accounts.find_by_goal_id(@goal)
    
    respond_to do |format|
      if new_follow
        flash[:notice] = "You're now following #{@goal.title}."
      else
        flash[:notice] = "You're already following #{@goal.title}."
      end        
      format.html { redirect_to @goal }
      format.xml  { render :xml => @account, :status => :created, :location => @account }
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = @goal.accounts.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to [@goal, @account], :notice => 'Account was successfully updated.' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = @goal.accounts.find(params[:id])
    @account.destroy

    respond_to do |format|
      flash[:notice] = 'You are no longer following this goal.'
      format.html { redirect_to(@goal) }
      format.xml  { head :ok }
    end
  end

  private

  def load_goal
    @goal = Goal.find(params[:goal_id]) unless params[:goal_id].nil?
  end

  def correct_user
    true
  end

end
