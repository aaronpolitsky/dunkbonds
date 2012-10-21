require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
    @goal = goals(:one)
    @treasury = accounts(:treasury)
    @acct = accounts(:acct)
    @goal.accounts << @treasury
    @goal.accounts << @acct
    @order = orders(:one)
    @bid_order = orders(:bid_order)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "should get new order unless cart is empty" do
    cart = current_cart
    cart.line_items << line_items(:t_bond_ask)

    assert_equal 1, cart.line_items.size
    get :new

    assert_response :success
  end

  test "should redirect to line_items if cart is empty" do
    get :new
    assert_redirected_to line_items_path
  end

  test "should create order if cart is not empty" do
    cart = current_cart
    t_bond_ask = @treasury.line_items.create!(:t_bond_ask)
#    t_bond_ask = line_items(:t_bond_ask)
    cart.line_items << t_bond_ask

    assert_difference('Order.count') do
      post :create, :order => @order.attributes
    end

    assert assigns(:order).line_items.count == 1
    assert session[:cart_id].nil?
    assert_redirected_to order_path(assigns(:order))
  end

  test "should match pending ask with new bid" do
    #set up pending bond bid from treasury
    treas_cart = current_cart
    t_bond_ask = line_items(:t_bond_ask)
    @treasury.line_items << t_bond_ask
    treas_cart.line_items << t_bond_ask

    assert_difference('Order.count') do
      post :create, :order => @order.attributes
    end
    assert assigns(:order).line_items.count == 1
    assert assigns(:order).line_items.first.status == "pending"    
    assert_nil session[:cart_id]

    #place and execute bond ask from account
    account_cart = current_cart
    a_bond_bid = line_items(:a_bond_bid)
    @acct.line_items << a_bond_bid
    account_cart.line_items << a_bond_bid
    assert_difference('Order.count') do
      post :create, :order => @bid_order.attributes
    end
    assert assigns(:order).line_items.count == 1
    assert assigns(:order).line_items.first.status == "executed"
    assert @acct.line_items.first.status == "executed"
    assert @treasury.line_items.first.status == "executed"
  end

  test "should update bond quantity instead of creating new bond row " do
    
  end

  test "should show order" do
    get :show, :id => @order.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @order.to_param
    assert_response :success
  end

  test "should update order" do
    put :update, :id => @order.to_param, :order => @order.attributes
    assert_redirected_to order_path(assigns(:order))
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete :destroy, :id => @order.to_param
    end

    assert_redirected_to orders_path
  end
end
