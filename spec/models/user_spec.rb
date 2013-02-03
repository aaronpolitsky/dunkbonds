require 'spec_helper'

describe User do
  before :each do
    @u = Factory.create(:user)
  end
  
  describe "has one" do
    describe "cart and" do
      it "responds to cart" do        
        @u.cart
      end

      it "creates its cart automatically" do
        expect {
          Factory.create(:asdf)
        }.to change(Cart, :count).by(1)
      end
    end
  end

  describe "has many" do
    describe "accounts and" do
      it "responds to accounts" do
        @u.should respond_to(:accounts)
      end
    end

    describe "followed goals through accounts and" do
      it "responds to followed_goals" do
        @u.should respond_to(:followed_goals)
      end
    end

    describe "line_items through accounts and" do
      it "responds to line_items" do
        g = Factory.create(:goal)
        @u.follow_goal(g)
        a = @u.accounts.last
        li = Factory.create(:line_item, :account => a)
        @u.should respond_to(:line_items)
        @u.line_items.should eq [li]
      end
    end

    describe "orders and" do
      it "responds to orders" do
        @u.should respond_to(:orders)
      end
    end

    describe "created goals and" do
    end
  end

  describe "can follow goals" do
    it "via user.follow_goal(goal)" do
      g = Factory.create(:goal)
      
      assert @u.followed_goals.empty?
      @u.follow_goal(g)
      assert @u.followed_goals.include?(g)
    end
    
    it "which creates a unique account with the goal" do
      g = Factory.create(:goal)
      
      @u.follow_goal(g)
      @u.follow_goal(g) #try it twice to test uniqueness
      @u.accounts.count.should eq 1
    end

  end

end
