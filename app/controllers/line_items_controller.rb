class LineItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_account

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
    @line_item = @account.line_items.new

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
    @cart = current_cart
    @line_item = @account.line_items.build(params[:line_item])

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
    @line_item = @account.line_items.find(params[:id])

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
      @line_item.destroy
      redirect_to(cart, :notice => 'Successfully updated cart.') 
    else #the line_item is already part of an order
      @line_item.cancel! if @line_item.status == "pending"
      redirect_to @line_item.order
    end
  end

  private

  def load_account
    @account = Account.find(params[:account_id]) 
  end

end

