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
    @goal = Factory.create(:goal)
  end

  # This should return the minimal set of attributes required to create a valid
  # LineItem. As you add validations to LineItem, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:qty => 2}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # LineItemsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

#  describe "GET index" do
#    it "assigns all line_items as @line_items" do
#      line_item = @goal.line_items.create! valid_attributes
#      get :index, {:goal_id => @goal.to_param, }, valid_session
#      assigns(:line_items).should eq([line_item])
#    end
#  end

  describe "GET show" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
      @user.follow_goal(@goal)
      @line_item = @goal.line_items.create!
      get :show, {:goal_id => @goal.to_param, :id => @line_item.to_param}, valid_session
    end

    it "assigns the requested line_item as @line_item" do
      assigns(:line_item).should eq(@line_item)
    end
    
    it "displays the line_item's details" do
      response.should have_selector ".line_items .line_item"
    end
  end

  describe "GET new" do
    before :each do
      get :new, {:goal_id => @goal.to_param}
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
        response.should have_selector 'form', :content => "Quantity"
      end
    end
  end

  describe "GET edit" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
      @user.follow_goal @goal
      @line_item = @goal.line_items.create!
      get :edit, { :goal_id => @goal.to_param, :id => @line_item.to_param }
    end

    describe "assigns" do
      it "the requested line_item as @line_item" do
        assigns(:line_item).should eq(@line_item)
      end
    end

  end

  describe "POST create" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
      @cart = subject.send(:current_cart)
    end
    
    it "creates a new LineItem" do
      expect {
        post :create, {:goal_id => @goal.to_param, :line_item => valid_attributes}#, valid_session
      }.to change(LineItem, :count).by(1)
    end
    
    describe "assigns" do
      it "a newly created line_item as @line_item" do
        post :create, {:goal_id => @goal.to_param, :line_item => valid_attributes}#, valid_session
        assigns(:line_item).should be_a(LineItem)
        assigns(:line_item).should be_persisted
      end
    end
    
    it "adds the new line_item to the user's cart" do
      expect {
        post :create, {:goal_id => @goal.to_param, :line_item => valid_attributes}#, valid_session
      }.to change(@cart.line_items, :count).by(1)
    end
    
    it "redirects to the user's cart" do
      post :create, {:goal_id => @goal.to_param, :line_item => valid_attributes}#, valid_session
      response.should redirect_to(@cart) #[@goal, @goal.line_items.last])
    end
    
    it "should notify that the item is in the cart" do
      post :create, {:goal_id => @goal.to_param, :line_item => valid_attributes}#, valid_session
      flash[:notice].should contain "We added the item to your cart."
    end
  
    it "creates the user's account the user isn't already following the goal" do
      expect {
        post :create, {:goal_id => @goal.to_param, :line_item => valid_attributes}#, valid_session          
      }.to change(@user.followed_goals, :count).by 1
    end
  end

  describe "PUT update" do
    describe "of a line_item that's in the cart" do
      before :each do
        @user = Factory.create(:user)
        sign_in @user
        @user.follow_goal(@goal)
        @line_item = @goal.line_items.create!
        @cart = subject.send(:current_cart)
        @cart.line_items << @line_item
      end
      
      it "updates the requested line_item" do
        # Assuming there are no other line_items in the database, this
        # specifies that the LineItem created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        LineItem.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:goal_id => @goal.to_param, :id => @line_item.to_param, :line_item => {'these' => 'params'}}
      end
      
      it "assigns the requested line_item as @line_item" do
        put :update, {:goal_id => @goal.to_param, :id => @line_item.to_param, :line_item => valid_attributes}
        assigns(:line_item).should eq(@line_item)
      end

      it "redirects to the user's cart" do
        put :update, {:goal_id => @goal.to_param, :id => @line_item.to_param, :line_item => valid_attributes}
        response.should redirect_to(@cart) #[@goal, @goal.line_items.last])
      end
    end
    
    describe "of a line_item already in an order" do
      before :each do
        @user = Factory.create(:user)
        sign_in @user
        @user.follow_goal(@goal)
        @line_item = @goal.line_items.create!
        @order = Factory.create(:order)
        @order.line_items << @line_item
      end

      it "does not update the requested line_item" do
        # Assuming there are no other line_items in the database, this
        # specifies that the LineItem created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        LineItem.any_instance.should_not_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:goal_id => @goal.to_param, :id => @line_item.to_param, :line_item => {'these' => 'params'}}
      end
      
      it "assigns the requested line_item as @line_item" do
        put :update, {:goal_id => @goal.to_param, :id => @line_item.to_param, :line_item => valid_attributes}
        assigns(:line_item).should eq(@line_item)
      end
      
      it "redirects back to the line_item" do
        put :update, {:goal_id => @goal.to_param, :id => @line_item.to_param, :line_item => valid_attributes}
        response.should redirect_to([@goal, @line_item]) #[@goal, @goal.line_items.last])
      end      
    end
  end

  describe "DELETE destroy" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
      @user.follow_goal(@goal)
      @line_item = @goal.line_items.create!
    end

    describe "of a line_item that's in the cart" do
      before :each do
        @cart = subject.send(:current_cart)
        @cart.line_items << @line_item
      end

      it "destroys the requested line_item" do
        expect {
          delete :destroy, {:goal_id => @goal.to_param, :id => @line_item.to_param}
        }.to change(LineItem, :count).by(-1)
      end

      it "removes it from its cart" do
        delete :destroy, {:goal_id => @goal.to_param, :id => @line_item.to_param}, {:cart_id => @cart.id}
        assert @cart.line_items.empty?
      end

      it "redirects to its cart" do
        delete :destroy, {:goal_id => @goal.to_param, :id => @line_item.to_param}, {:cart_id => @cart.id}
        response.should redirect_to(@cart)
        flash[:notice].should contain "Successfully updated cart."
      end
    end

    describe "of a line_item in an order" do
      before :each do
        @order = Factory.create(:order)
        @order.line_items << @line_item
      end

      it "does not destroy the requested line_item " do
        expect {
          delete :destroy, {:goal_id => @goal.to_param, :id => @line_item.to_param}
        }.to change(LineItem, :count).by(0)
      end

      pending "cancels the line item if possible" do

      end
    
      it  "redirects to its order" do
        delete :destroy, {:goal_id => @goal.to_param, :id => @line_item.to_param}
        response.should redirect_to(@order)
      end
    end
  end
end
