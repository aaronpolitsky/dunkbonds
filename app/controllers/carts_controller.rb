class CartsController < ApplicationController

  # GET /carts/1
  # GET /carts/1.xml
  def show
    @cart = current_or_guest_user.cart
    @line_items = @cart.line_items

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cart }
    end
  end

  

end
