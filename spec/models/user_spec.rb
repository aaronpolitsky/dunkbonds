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

    describe "orders and" do
      it "responds to orders" do
        u = Factory.create(:user)
        u.should respond_to(:orders)
      end
    end

    describe "created goals and" do
    end

  end
end
