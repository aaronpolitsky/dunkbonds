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

describe LineItemsController do
  render_views

  before :each do
    @user = Factory.create(:user)
    sign_in @user
    @goal = Factory.create(:goal)
    @user.follow_goal(@goal)
    @account = @user.accounts.last
    request.env["HTTP_REFERER"] = "where_i_came_from"
  end

  # This should return the minimal set of attributes required to create a valid
  # LineItem. As you add validations to LineItem, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :qty => 2,
      :max_bid_min_ask => 10,
      :type_of => "bond bid"
    }
  end


  describe "GET show" do
    before :each do
      @line_item = @account.line_items.create!  valid_attributes
      @line_item.execute!
      get :show, {:account_id => @account.to_param, :id => @line_item.to_param}
    end

    it "assigns the requested line_item as @line_item" do
      assigns(:line_item).should eq(@line_item)
    end
    
    it "displays the line_item's details" do
      response.should have_selector ".line_items .line_item"
    end

    it "displays the line_item's trades" do
      response.should have_selector ".line_items .line_item .trades .trade"
    end

    it "does not display trades for line_items without trades" do
      line_item = @account.line_items.create! valid_attributes.merge(:max_bid_min_ask => @goal.bond_face_value/2)
      line_item.execute!
      get :show, {:account_id => @account.to_param, :id => line_item.to_param }
      response.should_not have_selector ".line_items .line_item .trades"
    end
  end

  describe "GET new" do
    before :each do
      get :new, {:account_id => @account.to_param }
    end
    
    describe "assigns" do
      it "a new line_item as @line_item" do
        assigns(:line_item).should be_a_new(LineItem)
      end
    end
    
    describe "shows" do
      it "a heading Support <goal.title>" do 
        response.should have_selector 'h3', :content => "Support #{@goal.title}?" 
      end

      it "a qty input field" do
        response.should have_selector 'form', :content => "What quantity?"
      end
    end
  end

  describe "GET edit" do
    before :each do
      @line_item = @account.line_items.create!  valid_attributes
      get :edit, { :account_id => @account.to_param , :id => @line_item.to_param }
    end

    describe "assigns" do
      it "the requested line_item as @line_item" do
        assigns(:line_item).should eq(@line_item)
      end
    end

  end

  describe "POST create" do
    before :each do
      @cart = @user.cart
    end
    
    it "creates a new LineItem" do
      expect {
        post :create, {:account_id => @account.to_param , :line_item => valid_attributes}#
      }.to change(LineItem, :count).by(1)
    end
    
    describe "assigns" do
      it "a newly created line_item as @line_item" do
        post :create, {:account_id => @account.to_param , :line_item => valid_attributes}#
        assigns(:line_item).should be_a(LineItem)
        assigns(:line_item).should be_persisted
      end
    end
    
    it "adds the new line_item to the user's cart" do
      expect {
        post :create, {:account_id => @account.to_param , :line_item => valid_attributes}#
      }.to change(@cart.line_items, :count).by(1)
    end
    
    it "redirects to the user's cart" do
      post :create, {:account_id => @account.to_param , :line_item => valid_attributes}#
      response.should redirect_to(@cart) 
    end
    
    it "should notify that the item is in the cart" do
      post :create, {:account_id => @account.to_param , :line_item => valid_attributes}#
      flash[:notice].should contain "We added the item to your cart."
    end
  
  end

  describe "PUT update" do
    describe "of a line_item that's in the cart" do
      before :each do
        @line_item = @account.line_items.create!  valid_attributes
        @cart = @user.cart
        @cart.line_items << @line_item
      end
      
      it "updates the requested line_item" do
        # Assuming there are no other line_items in the database, this
        # specifies that the LineItem created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        LineItem.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:account_id => @account.to_param  , :id => @line_item.to_param, :line_item => {'these' => 'params'}}
      end

      describe "that's a swap bid" do
        it "updates its child ask qty if changed" do
          swap = @account.line_items.create!(:type_of => "swap bid",
                                             :qty => 1,
                                             :max_bid_min_ask => @goal.bond_face_value)
          child = swap.child
          @cart.line_items << swap
          @cart.line_items << child          
          put :update, {:account_id => @account.to_param  , :id => swap.to_param, :line_item => {:qty => 2}}
          swap.reload.qty.should eq 2
          swap.child.reload.qty.should eq 2
        end
      end

      describe "that's a child bond ask" do
        it "updates its qty and its parent's swap qty" do
          swap = @account.line_items.create!(:type_of => "swap bid",
                                             :qty => 1,
                                             :max_bid_min_ask => @goal.bond_face_value)
          child = swap.child
          @cart.line_items << swap
          @cart.line_items << child          
          put :update, {:account_id => @account.to_param  , :id => child.to_param, :line_item => {:qty => 2}}
          swap.reload.qty.should eq 2
          swap.reload.child.qty.should eq 2
        end
      end
      
      it "assigns the requested line_item as @line_item" do
        put :update, {:account_id => @account.to_param  , :id => @line_item.to_param, :line_item => valid_attributes}
        assigns(:line_item).should eq(@line_item)
      end

      it "redirects to the user's cart" do
        put :update, {:account_id => @account.to_param  , :id => @line_item.to_param, :line_item => valid_attributes}
        response.should redirect_to(@cart)
      end
    end
    
    describe "of a line_item already in an order" do
      before :each do
        @line_item = @account.line_items.create!  valid_attributes 
        @order = Factory.create(:order)
        @order.line_items << @line_item
      end

      it "does not update the requested line_item" do
        # Assuming there are no other line_items in the database, this
        # specifies that the LineItem created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        LineItem.any_instance.should_not_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:account_id => @account.to_param  , :id => @line_item.to_param, :line_item => {'these' => 'params'}}
      end
      
      it "assigns the requested line_item as @line_item" do
        put :update, {:account_id => @account.to_param  , :id => @line_item.to_param, :line_item => valid_attributes}
        assigns(:line_item).should eq(@line_item)
      end
      
      it "redirects back to the line_item" do
        put :update, {:account_id => @account.to_param  , :id => @line_item.to_param, :line_item => valid_attributes}
        response.should redirect_to([@account, @line_item])
      end      
    end
  end

  describe "DELETE destroy" do
    before :each do
      @line_item = @account.line_items.create!  valid_attributes
    end

    describe "of a line_item that's in the cart" do
      before :each do
        @cart = @user.cart
        @cart.line_items << @line_item
      end

      it "destroys the requested line_item" do
        expect {
          delete :destroy, {:account_id => @account.to_param  , :id => @line_item.to_param}
        }.to change(LineItem, :count).by(-1)
      end

      it "removes it from its cart" do
        delete :destroy, {:account_id => @account.to_param  , :id => @line_item.to_param}
        assert @cart.line_items.empty?
      end

      it "removes both it and its parent from the cart" do
        c = @line_item.create_child(:type_of => "bond ask",
                                    :account_id => @line_item.account.id,
                                    :qty => @line_item.qty,
                                    :cart_id => @line_item.cart_id,
                                    :max_bid_min_ask => @line_item.account.goal.bond_face_value)
        delete :destroy, {:account_id => @account.to_param  , :id => c.to_param}
        assert @cart.line_items.empty?
        LineItem.all.should eq []
      end

      it "removes both it and its child from the cart" do
        c = @line_item.create_child(:type_of => "bond ask",
                                    :account_id => @line_item.account.id,
                                    :qty => @line_item.qty,
                                    :cart_id => @line_item.cart_id,
                                    :max_bid_min_ask => @line_item.account.goal.bond_face_value)
        delete :destroy, {:account_id => @account.to_param  , :id => @line_item.to_param}
        assert @cart.line_items.empty?
        LineItem.all.should eq []
      end 

      it "redirects to its cart" do
        delete :destroy, {:account_id => @account.to_param  , :id => @line_item.to_param}
        response.should redirect_to(@cart)
        flash[:notice].should contain "Trade request removed from cart."
      end
    end

    describe "of a line_item in an order" do
      before :each do
        @order = Factory.create(:order)
        @order.line_items << @line_item
      end

      it "does not destroy the requested line_item " do
        expect {
          delete :destroy, {:account_id => @account.to_param  , :id => @line_item.to_param}
        }.to change(LineItem, :count).by(0)
      end

      it "cancels a pending line item" do
        @line_item.status = "pending"
        @line_item.save!
        delete :destroy, {:account_id => @account.to_param  , :id => @line_item.to_param}
        @line_item.reload
        @line_item.status.should eq "cancelled"
      end
    
      it  "redirects back" do
        delete :destroy, {:account_id => @account.to_param  , :id => @line_item.to_param}
        response.should redirect_to("where_i_came_from")
      end
    end
  end
end
