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

    it "have its bid be either a bond bid or a swap bid" do
      Factory.build(:trade, :bid => @bond_ask).should_not be_valid
      Factory.build(:trade, :bid => @swap_ask).should_not be_valid
    end
	end

	describe "creation" do
    describe "of a bond trade" do
      before :each do
        3.times { @treasury.transfer_bond_to!(@escrow) }
        @escrow.bonds.sum(:qty).should eq 3
        @escrow.balance = @bond_bid.qty * @bond_bid.max_bid_min_ask
        @escrow.save!
        @buyer.balance = -@escrow.balance
        @buyer.save!
        @buyer.bonds.count.should eq 0
        @bond_trade = @bond_bid.buys.new(:ask => @bond_ask,
                                         :qty => @bond_ask.qty,
                                         :price => @bond_ask.max_bid_min_ask/2)
      end
      
      it "transfers bonds from escrow to buyer" do
        @bond_trade.save!
        @buyer.reload.bonds.sum(:qty).should eq @bond_ask.qty
        @escrow.reload.bonds.sum(:qty).should eq (3-@bond_ask.qty)
      end

      it "transfers trade total from escrow to seller and returns change to buyer" do
        bb = @buyer.balance
        @bond_trade.save!
        @bond_trade.ask.account.reload.balance.should eq (@bond_trade.total)
        (@bond_trade.bid.account.reload.balance - bb).should eq (@bond_trade.total)
        @escrow.reload.balance.should eq 10
      end
           
    end

    describe "of a swap trade" do
      before :each do
        @swap_trade = @swap_bid.buys.new(:ask => @swap_ask,
                                         :qty => @swap_bid.qty,
                                         :price => @swap_ask.max_bid_min_ask)
      end
      
      it "does not transfer swaps from escrow to buyer" do
        @swap_trade.save!
        @buyer.reload.swaps.sum(:qty).should eq 0
        @escrow.reload.swaps.sum(:qty).should eq 0
      end

      it "transfers funds from buyer to treasury" do
        @swap_trade.save!
        @swap_trade.ask.account.reload.balance.should eq (@swap_trade.total)
      end
      
      pending "sets the qty and price automatically" do
        @swap_trade.save!
        @swap_trade.price.should eq @swap_ask.max_bid_min_ask
        @swap_trade.qty.should eq min(@swap_bid.qty, @swap_ask.qty)
      end      
    end

  end   

end	
