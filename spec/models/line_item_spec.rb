require 'spec_helper'

describe LineItem do
  before do
    @user  = Factory.create(:user)
    @goal = Factory.create(:goal)
    @user.follow_goal(@goal)
  end
  
  describe "belongs to" do
    describe "a goal and" do
      it "responds to goal" do
        l = @goal.line_items.create!
        l.should respond_to(:goal)
      end
    end

    describe "a cart and" do
      it "responds to cart" do
        l = @goal.line_items.create!
        l.should respond_to(:cart)
      end
    end

    describe "an order and" do
      it "responds to order" do
        l = @goal.line_items.create!
        l.should respond_to(:order)
      end
    end
  end  

  it "responds to account" do
    l = @goal.line_items.create!
    l.should respond_to(:account)
  end

  describe "must" do #validations
    it "have a valid quantity" do
      @goal.line_items.new(:qty => 0).should_not be_valid
      @goal.line_items.new(:qty => -1).should_not be_valid
      @goal.line_items.new(:qty => 101).should_not be_valid
      @goal.line_items.new(:qty => 100).should be_valid
    end
  end

  it "should have an initial status of new" do
    l = @goal.line_items.create!
    l.status.should eq "new"
  end

  describe "find_matching_asks" do
      describe "for qty 1" do
        it "should find the earliest best ask" do
          bestask = Factory.create(:ask, :qty => 1, :created_at => Time.now)
          laterask = Factory.create(:ask, :qty => 1, :created_at => bestask.created_at + 1.hour)
          priceyask = Factory.create(:ask, :qty => 1, :max_bid_min_ask => 11, :created_at => bestask.created_at)
          bid = Factory.create(:bid, :qty => 1)
          matches = bid.find_matching_asks
          matches.should eq [bestask]
          matches.should_not eq [priceyask]
          matches.should_not eq [laterask]
        end
      end
      
      describe "for qty n > 1" do
        it "should return [] if < n matching asks exist" do
          ask = Factory.create(:ask, :qty => 1)
          bid = Factory.create(:bid, :qty => 2)
          bid.find_matching_asks.should eq []
        end
        
        it "should split the last match if it is of greater qty than required" do
          bid = Factory.create(:bid, :qty => 2)
          ask = Factory.create(:ask, :qty => 3)
          matches = bid.find_matching_asks
          matches.should_not eq ask
          matches.last.qty.should eq bid.qty
          matches.last.should eq LineItem.last
        end

        describe "should find n of the earliest best asks" do
          it "even if from > 1 matches" do
            bid = Factory.create(:bid, :qty => 2)
            best_asks = []
            3.times  { best_asks << Factory.create(:ask, :qty => 1, :created_at => Time.now) }
            matches = bid.find_matching_asks
            matches.should eq best_asks[0..1]
            matches.should_not eq best_asks
          end
        end
      end
  end
end
