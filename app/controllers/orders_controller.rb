class OrdersController < ApplicationController

  before_filter :authenticate_user!

  # GET /orders
  # GET /orders.xml
  def index
    @orders = current_user.orders
    @order_line_items = Hash.new
    @orders.each do |o|
      @order_line_items.store o, o.line_items
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.xml
  def show
    @order = current_user.orders.find(params[:id])
    @line_items = @order.line_items

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.xml
  def new
    @order = current_user.orders.new
    @cart = @order.user.cart

    respond_to do |format|
      if @cart.line_items.empty?
        format.html { redirect_to @cart, :notice => "Your cart is empty." }
      else
        format.html # new.html.erb
        format.xml  { render :xml => @order }
      end
    end
  end

  # GET /orders/1/edit
  def edit
    @order = current_user.orders.find(params[:id])
  end

  # POST /orders
  # POST /orders.xml
  def create
    @order = current_user.orders.new(params[:order])
    
    respond_to do |format|
      if @order.save
        @order.get_cart_items
        @order.execute_line_items
        format.html { redirect_to(@order, :notice => 'Order was successfully created.') }
        format.xml  { render :xml => @order, :status => :created, :location => @order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.xml
  def update
    @order = current_user.orders.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        format.html { redirect_to(@order, :notice => 'Order was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.xml
  def destroy
    @order = current_user.orders.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to(orders_url) }
      format.xml  { head :ok }
    end
  end

end
