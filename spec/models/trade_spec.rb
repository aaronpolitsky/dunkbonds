require 'spec_helper'

describe Trade do
  before :each do
    @user = Factory.create(:user)
    @goal = Factory.create(:goal)
    @user.follow_goal(@goal)
    @buyer  = @user.accounts.last
    @treasury = Factory.create(:account, :is_treasury => true)
    @goal.accounts << @treasury
  
  	@bid = Factory.create(:bid, :account => @buyer)
  	@ask = Factory.create(:ask, :account => @treasury)
    @user.orders.create!
    @user.orders.first.line_items << @bid
   
  	@t = @bid.buys.create!(:ask_id => @ask.id, :qty => 1, :price => 10.0)
  end		

  describe "belongs to stuff and" do
  	it "responds to stuff" do
  		@t.should respond_to :bid_id
  		@t.should respond_to :ask_id
  	end	
  end		


  describe "must" do #validations
    it "have a valid quantity and price" do
	    @bid.buys.new(:ask_id => @ask, :price => 10, :qty => 0).should_not be_valid
      @bid.buys.new(:ask_id => @ask, :price => 10, :qty => -1).should_not be_valid
  		@bid.buys.new(:ask_id => @ask, :qty => 2).should_not be_valid
  		@bid.buys.new(:ask_id => @ask, :price => -1.2, :qty => 2).should_not be_valid
    end

    it "belong to both a bid and an ask" do
    	Factory.build(:trade).should_not be_valid
    	Factory.build(:trade, :bid_id => @bid).should_not be_valid
    	Factory.build(:trade, :ask_id => @ask).should_not be_valid
    end	
	end

	describe "creation" do
    
    it "executes the trade" do
      bid = Factory.create(:bid, :account => @buyer)
      t = bid.buys.new(:ask_id => @ask, :price => @ask.max_bid_min_ask, :qty => @ask.qty)
      bal = @buyer.balance
      # expect{
      t.save!
      # }.to change(@buyer.reload, :balance).by (-t.price * t.qty)
      (bal - @buyer.reload.balance).should eq (t.price * t.qty)
    end
  end   

end	
