require 'spec_helper'

describe User do
  describe "has many" do
    describe "accounts and" do
      it "responds to accounts" do
        u = Factory.create(:user)
        u.should respond_to(:accounts)
      end
    end

    describe "followed goals through accounts and" do
      it "responds to followed_goals" do
        u = Factory.create(:user)
        u.should respond_to(:followed_goals)
      end
    end

    describe "line_items through accounts and" do
      it "responds to line_items" do
        u = Factory.create(:user)
        g = Factory.create(:goal)
        u.follow_goal(g)
        a = u.accounts.last
        li = Factory.create(:line_item, :account => a)
        u.should respond_to(:line_items)
        u.line_items.should eq [li]
      end
    end

    describe "orders and" do
      it "responds to orders" do
        u = Factory.create(:user)
        u.should respond_to(:orders)
      end
    end

    describe "created goals and" do
    end
  end

  describe "can follow goals" do
    it "via user.follow_goal(goal)" do
      g = Factory.create(:goal)
      u = Factory.create(:user)
      assert u.followed_goals.empty?
      u.follow_goal(g)
      assert u.followed_goals.include?(g)
    end
    
    it "which creates a unique account with the goal" do
      g = Factory.create(:goal)
      u = Factory.create(:user)
      u.follow_goal(g)
      u.follow_goal(g) #try it twice to test uniqueness
      u.accounts.count.should eq 1
    end

  end

end
