class LineItemsController < ApplicationController
#  before_filter :authenticate_user!
  before_filter :load_account_and_goal
  before_filter :line_item_exists?, :except => [:index, :new, :create]
  before_filter :goal_market_open?, :except => [:index, :show]

  def index
    @line_items = @account.line_items

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @line_items }
    end
  end

  # GET /line_items/1
  # GET /line_items/1.xml
  def show
    @line_item = @account.line_items.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @line_item }
    end
  end

  # GET /line_items/new
  # GET /line_items/new.xml
  def new
    if liparams = session[:liparams] 
      if liparams[:type_of] == "swap bid"
        @line_item = @account.line_items.new(liparams.merge(:max_bid_min_ask => @goal.bond_face_value))
      else
        @line_item = @account.line_items.new(liparams)
      end      
    else
      @line_item = @account.line_items.new
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @line_item }
    end
  end

  # GET /line_items/1/edit
  def edit 
    @line_item = @account.line_items.find(params[:id])
  end

  # POST /line_items
  # POST /line_items.xml
  def create
    @cart = current_or_guest_user.cart
    @line_item = @account.line_items.build(params[:line_item])

    respond_to do |format|
      if @line_item.save
        @cart.line_items << @line_item

        if @line_item.type_of == "swap bid"
          @bond_ask = @line_item.child
          @cart.line_items << @bond_ask
          format.html {redirect_to edit_account_line_item_path(@account, @bond_ask), :notice => "Now please fill in the details of how you'd like to sell these bonds." }
        else         
          session[:liparams] = nil
          format.html { redirect_to(@cart, :notice => 'Trade Request added to cart.') }
          format.xml  { render :xml => @line_item.cart, :location => @line_item.cart }
        end
        # end
      else  
        format.html { render :action => "new" }
        format.xml  { render :xml => @line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /line_items/1
  # PUT /line_items/1.xml
  def update
    @line_item = @account.line_items.find(params[:id])

    unless @line_item.cart.nil?
      @cart = @line_item.cart 

      respond_to do |format|
        if @line_item.update_attributes(params[:line_item])
          if @line_item.type_of == "swap bid"
            @bond_ask = @line_item.child
            @cart.line_items << @bond_ask
            format.html {redirect_to edit_account_line_item_path(@account, @bond_ask), :notice => "We added the request to your cart.  Now please fill in the details of how you'd like to sell these bonds." }
          else
            session[:liparams] = nil
            format.html { redirect_to(@cart, :notice => 'Trade Request updated.') }
            format.xml  { render :xml => @line_item.cart, :location => @line_item.cart }
          end
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @line_item.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to([@account, @line_item], :notice => 'You cannot update this item.') }
        format.xml  { head :ok }
      end
    end
  end

  # DELETE /line_items/1
  # DELETE /line_items/1.xml
  def destroy
    @line_item = @account.line_items.find(params[:id])

    unless @line_item.cart.nil?
      cart = @line_item.cart 
      relative = @line_item.child if @line_item.child
      relative = @line_item.parent if @line_item.parent_id
      @line_item.destroy
      relative.destroy if relative
      redirect_to(new_account_line_item_path, :notice => 'Trade request removed from cart.') 
    else #the line_item is already part of an order
      @line_item.cancel! if @line_item.status == "pending"
      redirect_to(:back, :notice => 'Trade request canceled.')
    end
  end

  private

  def goal_market_open?
    load_account_and_goal
    if @goal.status == 'Achieved'
      flash[:warning] = "This goal has been achieved, and its market is now closed."
      redirect_to @goal
    elsif @goal.status == 'Expired'
      flash[:warning] = "This goal has expired, and its market is now closed."
      redirect_to @goal
    end
  end

  def load_account_and_goal
    if current_or_guest_user.accounts.exists?(params[:account_id])
      @account = current_or_guest_user.accounts.find(params[:account_id])  
      @goal = @account.goal
    else
      flash[:warning] = "Cut it out."
      redirect_to accounts_path
    end
  end

  def line_item_exists?
    load_account_and_goal
    @line_item = @account.line_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "That Trade Request does not exist."
    redirect_to [@goal, @account]
  end

end
