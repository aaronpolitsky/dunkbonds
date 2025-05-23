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

describe AccountsController do
  render_views

  before :each do
    @goal = Factory.create(:goal)
  end

  # This should return the minimal set of attributes required to create a valid
  # Account. As you add validations to Account, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :is_treasury => false,
      :is_escrow => false
    }
  end

  def valid_line_item_attributes
    {
      :qty => 2,
      :max_bid_min_ask => @goal.bond_face_value,
      :type_of => "bond bid"
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AccountsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
      @user.follow_goal(@goal)
      @account = @user.accounts.last
    end

    it "assigns all accounts as @accounts" do
      get :index, {:goal_id => @goal.to_param }
      assigns(:accounts).should eq([@account])
    end
  end

  describe "GET show" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
      @user.follow_goal(@goal)
      @account = @user.accounts.last
    end

    describe "assigns" do 
      it "the requested account as @account" do
        get :show, {:goal_id => @goal.to_param, :id => @account.to_param}
        assigns(:account).should eq(@account)
      end
    end
    
    describe "shows" do

      it "its bonds and swaps counts" do
        @account.bonds.create!(:debtor => @treasury, :qty => 5)
        @account.swaps.create!(:creditor => Factory.create(:account, :goal => @goal), :qty => 6)        
        get :show, {:goal_id => @goal.to_param, :id => @account.to_param}      
        response.should have_selector ".bonds", :content => "bonds owned:  5"
        response.should have_selector ".swaps", :content => "swaps owned:  6"
      end
      
      describe "its history" do
        describe "which contains its" do 

          before :each do
            @cart = @user.cart
            3.times do
              o = @user.orders.create!
              2.times { o.line_items << @account.line_items.create!(valid_line_item_attributes) }
              1.times { @cart.line_items << @account.line_items.create!(valid_line_item_attributes) } 
            end
          end

          it "ordered line items" do          
            line_items = @account.line_items.where("order_id IS NOT NULL")
            cart_line_items  = @account.line_items.where("cart_id IS NOT NULL")
            get :show, {:goal_id => @goal.to_param, :id => @account.to_param}      
            assigns(:line_items).should_not include(cart_line_items)
            response.should have_selector ".line_items .line_item"
            assigns(:line_items).should eq(line_items)
            response.should have_selector ".line_items .line_item"
          end

          it "trades" do 
            pending "tested by line items controller"
            @account.line_items.where(:order_id).each do |li|
              li.execute!
            end
            get :show, {:goal_id => @goal.to_param, :id => @account.to_param} 
            response.should have_selector ".trades .trade" 
          end
          it "payments" do 
          end

        end
      end

    end
    
  

    it "should redirect to sign_in if not signed in" do
      sign_out @user
      get :show, {:goal_id => @goal.to_param, :id => @account.to_param}      
      response.should redirect_to new_user_session_path
    end
  end

  describe "GET new" do
    before :each do
      get :new, {:goal_id => @goal.to_param}
    end

    describe "assigns" do
      it "a new account as @account" do
        assigns(:account).should be_a_new(Account)
      end
    end

    describe "shows" do
      it "A heading Follow <goal.title>?" do
        response.should have_selector 'h3', :content => "Follow #{@goal.title}?" 
      end

      it "an explanation of how following and creating an account are linked" do
        response.should have_selector '#following_explanation'
      end

      it "" do

      end
    end
  end

  describe "GET edit" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
      @user.follow_goal(@goal)
      @account = @user.accounts.last
    end

    it "assigns the requested account as @account" do
      get :edit, { :goal_id => @goal.to_param, :id => @account.to_param }
      assigns(:account).should eq(@account)
    end
  end

  describe "POST create" do
    before :each do
      sign_in @user = Factory.create(:user)
    end
    
    it "creates a new Account" do
      expect {
        post :create, {:goal_id => @goal.to_param, :account => valid_attributes}#
      }.to change(Account, :count).by(1)
    end
    
    it "assigns a newly created account as @account" do
      post :create, {:goal_id => @goal.to_param, :account => valid_attributes}#
      assigns(:account).should be_a(Account)
      assigns(:account).should be_persisted
    end
    
    describe "redirects to" do
      it "the goal" do
        post :create, {:goal_id => @goal.to_param, :account => valid_attributes}#
        response.should redirect_to @goal
      end
    end
    
  end

  describe "PUT update" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
      @user.follow_goal(@goal)
      @account = @user.accounts.last
    end

    describe "with valid params" do
      it "updates the requested account" do
        # Assuming there are no other accounts in the database, this
        # specifies that the Account created 
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Account.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:goal_id => @goal.to_param, :id => @account.to_param, :account => {'these' => 'params'}}
      end

      it "assigns the requested account as @account" do
        put :update, {:goal_id => @goal.to_param, :id => @account.to_param, :account => valid_attributes}
        assigns(:account).should eq(@account)
      end

      it "redirects to the account" do
        put :update, {:goal_id => @goal.to_param, :id => @account.to_param, :account => valid_attributes}
        response.should redirect_to([@goal, @account])
      end
    end

    describe "with invalid params" do
      it "assigns the account as @account" do
        # Trigger the behavior that occurs when invalid params are submitted
        Account.any_instance.stub(:save).and_return(false)
        put :update, {:goal_id => @goal.to_param, :id => @account.to_param, :account => {}}
        assigns(:account).should eq(@account)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Account.any_instance.stub(:save).and_return(false)
        put :update, {:goal_id => @goal.to_param, :id => @account.to_param, :account => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
      @user.follow_goal(@goal)
      @account = @user.accounts.last
    end

    describe "for the correct user" do
      
      it "destroys the requested account" do
        expect {
          delete :destroy, {:goal_id => @goal.to_param, :id => @account.to_param}
        }.to change(Account, :count).by(-1)
      end
      
      it "redirects to that goal" do
        delete :destroy, {:goal_id => @goal.to_param, :id => @account.to_param}
        response.should redirect_to(@goal)
        flash[:notice].should contain "You are no longer following this goal."
      end
    end

    describe "for the incorrect user" do
      pending "does not destroy the requested account"
      pending "redirects to that goal"
    end
  end

end
