require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe OrdersController do
  render_views

  before :each do
    @goal = Factory.create(:goal)
    @user = Factory.create(:user)
    sign_in @user
    @user.follow_goal(@goal)
    @account = @user.accounts.last
  end

  # This should return the minimal set of attributes required to create a valid
  # Order. As you add validations to Order, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # OrdersController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    before :each do
      2.times {@user.orders.create!}
      @orders = @user.orders
      @order_line_items = Hash.new      
      @user.orders.each do |o| 
        2.times { o.line_items << Factory.create(:line_item, :account => @account) }
        @order_line_items.store o, o.line_items
      end
    end

    describe "for signed in users" do
      describe "assigns" do
        it "all orders as @orders" do
          get :index, {}
          assigns(:orders).should eq(@orders)
        end
        
        it "all line items as a hash on order" do
          get :index, {}
          assigns(:order_line_items).should eq(@order_line_items)
        end
      end
      
      describe "shows" do
        it "each order's line items" do
          get :index, {}
          response.should have_selector '.orders' 
          response.should have_selector '.order .line_item'
        end
        
        it "shows only this user's orders" do
          other_order = Factory.create(:order)
          get :index, {}
          assigns(:orders).should_not include(other_order)
          assigns(:orders).should eq(@orders)
        end
      end
    end
  end

  describe "GET show" do
    it "assigns the requested order as @order" do
      order = @user.orders.create! valid_attributes
      get :show, {:id => order.to_param}
      assigns(:order).should eq(order)
    end

    it "displays a list of its line items if it has any" do
      order = @user.orders.create! valid_attributes
      2.times { order.line_items << Factory.create(:line_item, :account => @account) }
      get :show, {:id => order.to_param}
      response.should have_selector ".line_items .line_item"      
    end
  end

  describe "GET new" do
    it "assigns a new order as @order" do
      get :new, {}
      assigns(:order).should be_a_new(Order)
    end
  end
  
  describe "ORDER create" do
    describe "with valid params" do
      it "creates a new Order" do
        expect { post :create, {:order => valid_attributes} }.to change(Order, :count).by(1)
      end

      it "assigns a newly created order as @order" do
        post :create, {:order => valid_attributes}
        assigns(:order).should be_a(Order)
        assigns(:order).should be_persisted
      end

      it "redirects to the created order" do
        post :create, {:order => valid_attributes}
        response.should redirect_to(Order.last)
      end

      it "gets all the cart line_items" do
        li = @account.line_items.create!(:qty => 1,
                                         :max_bid_min_ask => 10,
                                         :type_of => "bond bid")
        @user.cart.line_items << li
        post :create, {:order => valid_attributes}
        @user.cart.line_items.empty?.should eq true
        Order.last.line_items.should include li
      end

      it "does not delete the user's cart" do
        post :create, {:order => valid_attributes}        
        @user.cart.should_not be nil
      end

      describe "that results in pending line items" do

        it "attempts to execute existing pending line items" do
          user2 = Factory.create(:asdf)
          sign_in user2
          user2.follow_goal(@goal)
          otheracc = user2.accounts.last
          otheracc.bonds.create!(:debtor => @goal.treasury, :qty => 2)
          oli1 = otheracc.line_items.create!(:qty => 2,
                                             :type_of => "bond ask",
                                             :max_bid_min_ask => @goal.bond_face_value/2-1)
          oli1.execute!
          oli1.status.should eq "pending"
          otheracc.bonds.create!(:debtor => @goal.treasury, :qty => 2)
          oli2 = otheracc.line_items.create!(:qty => 2,
                                             :type_of => "bond ask",
                                             :max_bid_min_ask => @goal.bond_face_value/2-1)
          oli2.execute!
          oli2.status.should eq "pending"
          sign_out user2
          sign_in @user

          li1 = @account.line_items.create!(:qty => 1,
                                            :max_bid_min_ask => @goal.bond_face_value/2,
                                            :type_of => "bond bid")
          @user.cart.line_items << li1
          post :create, {:order => valid_attributes}          
          oli1.reload.status.should eq "pending"
          oli2.reload.status.should eq "pending"                    
          li1.reload.status.should eq "pending"
          li2 = @account.line_items.create!(:qty => 1,
                                            :max_bid_min_ask => @goal.bond_face_value/2,
                                            :type_of => "bond bid")          
          @user.cart.line_items << li2
          post :create, {:order => valid_attributes}
          oli1.reload.status.should eq "executed"
          oli2.reload.status.should eq "pending"
          li1.reload.status.should eq "executed"
          li2.reload.status.should eq "executed"
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved order as @order" do
          # Trigger the behavior that occurs when invalid params are submitted
          Order.any_instance.stub(:save).and_return(false)
          post :create, {:order => {}}
          assigns(:order).should be_a_new(Order)
        end
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Order.any_instance.stub(:save).and_return(false)
        post :create, {:order => {}}
        response.should render_template("new")
      end
    end
  end

end
