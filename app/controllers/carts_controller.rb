class CartsController < ApplicationController
  def show

  end

  def add_to_cart
    @order = params[:order]
    if session[:orders].nil?
      session[:orders] = []
    end
    session[:orders] << @order
    render 'show'
  end

  

end
