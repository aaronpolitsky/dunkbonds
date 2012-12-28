require 'spec_helper'

describe LineItem do
  before do
    @user = Factory.create(:user)
    @goal = Factory.create(:goal)
  end
  
  describe "belongs to" do
    describe "a goal and" do
      it "responds to goal" do
        l = @goal.line_items.create!#(:account => @account)
        l.should respond_to(:goal)
      end
    end

    describe "a cart and" do
      it "responds to cart" do
        l = @goal.line_items.create!#(:account => @account)
        l.should respond_to(:cart)
      end
    end

    describe "an order and" do
      it "responds to order" do
        l = @goal.line_items.create!#(:account => @account)
        l.should respond_to(:order)
      end
    end
  end  

  describe "must" do #validations

  end

  it "should have an initial status of new" do
    l = @goal.line_items.create!#(:account => @account)
    l.status.should eq "new"
  end

end
