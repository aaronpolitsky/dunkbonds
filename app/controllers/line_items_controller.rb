class LineItemsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :load_or_create_account, :only => :create
  before_filter :load_goal

  # GET /line_items/1
  # GET /line_items/1.xml
  def show
    @line_item = @goal.line_items.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @line_item }
    end
  end

  # GET /line_items/new
  # GET /line_items/new.xml
  def new
    @line_item = @goal.line_items.new
    @account = Account.new #dummy until created

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @line_item }
    end
  end

  # GET /line_items/1/edit
  def edit
    @line_item = @goal.line_items.find(params[:id])
    @account = @line_item.account
  end

  # POST /line_items
  # POST /line_items.xml
  def create
    @cart = current_cart
    params[:line_item][:account_id] = @account.id
    @line_item = @goal.line_items.build(params[:line_item])

    respond_to do |format|
      if @line_item.save
        @cart.line_items << @line_item
        format.html { redirect_to(@cart, :notice => 'We added the item to your cart.') }
        format.xml  { render :xml => @line_item.cart, :location => @line_item.cart }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /line_items/1
  # PUT /line_items/1.xml
  def update
    @line_item = @goal.line_items.find(params[:id])
    
    unless @line_item.cart.nil?
      cart = @line_item.cart 

      respond_to do |format|
        if @line_item.update_attributes(params[:line_item])
          format.html { redirect_to(cart, :notice => 'Line item was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @line_item.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to([@goal, @line_item], :notice => 'You cannot update this item.') }
        format.xml  { head :ok }
      end
    end
  end

  # DELETE /line_items/1
  # DELETE /line_items/1.xml
  def destroy
    @line_item = @goal.line_items.find(params[:id])

    unless @line_item.cart.nil?
      cart = @line_item.cart 
      @line_item.destroy
      redirect_to(cart, :notice => 'Successfully updated cart.') 
    else #the line_item is already part of an order
      redirect_to @line_item.order
    end
  end

  private

  def load_goal
    @goal = Goal.find(params[:goal_id]) unless params[:goal_id].nil?
  end

  def load_or_create_account
    current_user.follow_goal(load_goal)
    @account = current_user.accounts.find_by_goal_id(@goal)
  end
end

