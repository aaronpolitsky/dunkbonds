require 'spec_helper'

describe Cancellation do
	before :each do
    @user = Factory.create(:user)
    @goal = Factory.create(:goal)
    @user.follow_goal(@goal)
    @buyer  = @user.accounts.last
    @treasury = @goal.treasury
    @escrow = @goal.escrow
  
  	@bond_bid = Factory.create(:bond_bid, :account => @buyer, :qty => 2)
  	@bond_ask = Factory.create(:bond_ask, :account => @treasury)
    @swap_bid = Factory.create(:swap_bid, :account => @buyer, :qty => 2)
    @swap_ask = Factory.create(:swap_ask, :account => @treasury)
  end

	describe "belongs to line_item and" do
  	it "responds to line_item" do
			c = @bond_bid.create_cancellation! 
			c.should respond_to :line_item
  	end
  end	
end
