require 'spec_helper'

describe Trade do
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

  describe "belongs to stuff and" do
  	it "responds to stuff" do
      @t = @bond_bid.buys.create!(:ask_id => @bond_ask.id, :qty => 1, :price => 10.0)
  		@t.should respond_to :bid_id
  		@t.should respond_to :ask_id
  	end	
  end		

  describe "must" do #validations
    it "have a valid quantity and price" do
	    @bond_bid.buys.new(:ask_id => @bond_ask, :price => 10, :qty => 0).should_not be_valid
      @bond_bid.buys.new(:ask_id => @bond_ask, :price => 10, :qty => -1).should_not be_valid
  		@bond_bid.buys.new(:ask_id => @bond_ask, :qty => 2).should_not be_valid
  		@bond_bid.buys.new(:ask_id => @bond_ask, :price => -1.2, :qty => 2).should_not be_valid
    end

    it "belong to both a bid and an ask" do
    	Factory.build(:trade).should_not be_valid
    	Factory.build(:trade, :bid_id => @bond_bid).should_not be_valid
    	Factory.build(:trade, :ask_id => @bond_ask).should_not be_valid
    end	
	end

	describe "creation" do
    describe "of a bond trade" do
      before :each do
        3.times { @treasury.transfer_bond_to!(@escrow) }
        @escrow.bonds.sum(:qty).should eq 3
        @buyer.bonds.count.should eq 0
        @bond_trade = @bond_bid.buys.new(:ask => @bond_ask,
                                         :qty => @bond_bid.qty,
                                         :price => @bond_ask.max_bid_min_ask)
      end
      
      it "transfers bonds from escrow to buyer" do
        @bond_trade.save!
        @buyer.reload.bonds.sum(:qty).should eq @bond_bid.qty
        @escrow.reload.bonds.sum(:qty).should eq (3-@bond_bid.qty)
      end

      it "transfers funds from escrow to seller" do
        @bond_trade.save!
        @bond_trade.ask.account.reload.balance.should eq (@bond_trade.price * @bond_trade.qty)
        @escrow.reload.balance.should eq (-@bond_trade.price * @bond_trade.qty)
      end
           
    end

    describe "of a swap trade" do
      before :each do
        3.times { @treasury.transfer_swap_to!(@escrow) }
        @escrow.swaps.sum(:qty).should eq 3
        @buyer.swaps.count.should eq 0
        # @buyer.transfer_funds_to(@swap_bid.qty * @swap_bid.price, @escrow)
        # @buyer.balance.should be @swap_bid.qty * -@swap_bid.price
        @swap_trade = @swap_bid.buys.new(:ask => @swap_ask,
                                         :qty => @swap_bid.qty,
                                         :price => @swap_ask.max_bid_min_ask)
      end
      
      it "transfers swaps from escrow to buyer" do
        @swap_trade.save!
        @buyer.reload.swaps.sum(:qty).should eq @swap_bid.qty
        @escrow.reload.swaps.sum(:qty).should eq (3-@swap_bid.qty)
      end

      it "transfers funds from escrow to seller" do
        @swap_trade.save!
        @swap_trade.ask.account.reload.balance.should eq (@swap_trade.price * @swap_trade.qty)
        @escrow.reload.balance.should eq (-@swap_trade.price * @swap_trade.qty)
      end
      
      pending "sets the qty and price automatically" do
        @swap_trade.save!
        @swap_trade.price.should eq @swap_ask.max_bid_min_ask
        @swap_trade.qty.should eq min(@swap_bid.qty, @swap_ask.qty)
      end      
    end

  end   

end	
