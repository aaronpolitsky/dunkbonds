require 'spec_helper'

describe LineItem do
  before do
    @goal = Factory.create(:goal)
    @face = 10.0
    @buyer = @goal.accounts.create!
    @seller = @goal.accounts.create!
    @escrow   = @goal.escrow
    @treasury = @goal.treasury
  end
  
  describe "belongs to" do
    
    describe "stuff and" do
      it "responds to stuff" do
        l = @buyer.line_items.create!(:qty => 1)
        l.should respond_to(:cart)
        l.should respond_to(:order)
        l.should respond_to(:account) 
        l.reload.account.should eq @buyer     
      end
    end
  end  

  describe "can have many trades" do
    it "and responds to buys" do
      l = @buyer.line_items.create!(:qty => 1)
      l.should respond_to(:buys)   
    end
    
    it "and responds to sells" do
      l = @buyer.line_items.create!(:qty => 1)
      l.should respond_to(:sells)   
    end
  end 

  describe "must" do #validations
    it "have a valid quantity" do
      @buyer.line_items.new(:qty => 0).should_not be_valid
      @buyer.line_items.new(:qty => -1).should_not be_valid
      @buyer.line_items.new(:qty => 101).should_not be_valid
      @buyer.line_items.new(:qty => 100).should be_valid
    end

    it "have an account" do
      LineItem.new(:qty => 1).should_not be_valid
    end
  end

  it "should have an initial status of new" do
    l = @buyer.line_items.create!(:qty => 1)
    l.status.should eq "new"
  end

  describe "find_matching_bond_asks" do

    describe "when max_bid_min_ask is less than face value and qty is 1" do
      before :each do
        @ba = @buyer.line_items.create!(:max_bid_min_ask => @face - 1,
                                        :qty => 1)
      end

      describe "and there are bond_asks with compatible prices" do

        describe "if swap_bids exist" do

          it "prioritizes swap bond_bids over used bond_asks" do

          end

          it "backfills with non-swap bond_asks" do

          end

        end 

        describe "and swap_bids do not exist" do
          it "does not find matches" do

          end
        end
        
      end 
    end 


    describe "when max_bid_min_ask is less than face value and qty is > 1" do


    end


    describe "when price is $face value" do

      describe "when no other matches exist" do
        it "the treasury creates a matching ask" do

        end

        it ""
      end

      describe "when a pending swap_bid exists" do
        it "matches to the swap owner bond_ask" do

        end

        it "bond_asks match once "

      end

    end 
    
    describe "for qty 1" do
      it "should find the earliest best bond ask" do
        bestask = Factory.create(:bond_ask, :account => @seller, :created_at => Time.now)
        laterask = Factory.create(:bond_ask, :account => @seller, :created_at => bestask.created_at + 1.hour)
        priceyask = Factory.create(:bond_ask, :account => @seller, :max_bid_min_ask => 11, :created_at => bestask.created_at)
        bid = Factory.create(:bond_bid, :account => @buyer)
        matches = bid.find_matching_bond_asks
        matches.should eq [bestask]
        matches.should_not eq [priceyask]
        matches.should_not eq [laterask]
      end
    end
    
    describe "for qty n > 1" do
      it "should return [] if < n matching asks exist" do
        ask = Factory.create(:bond_ask, :qty => 1, :account => @seller)
        bid = Factory.create(:bond_bid, :qty => 2, :account => @buyer)
        bid.find_matching_bond_asks.should eq []
      end
      
      it "should split the last match if it is of greater qty than required" do
        bid = Factory.create(:bond_bid, :qty => 2, :account => @buyer)
        ask = Factory.create(:bond_ask, :qty => 3, :account => @seller)
        matches = bid.find_matching_bond_asks
        matches.should_not eq ask
        matches.last.qty.should eq bid.qty
        matches.last.should eq LineItem.last
      end
      
      describe "should find n of the earliest best asks" do
        it "even if from > 1 matches" do
          bid = Factory.create(:bond_bid, :qty => 2, :account => @buyer)
          best_asks = []
          3.times  { best_asks << Factory.create(:bond_ask, :account => @seller) }
          matches = bid.find_matching_bond_asks
          matches.should eq best_asks[0..1]
          matches.should_not eq best_asks
        end
      end
    end
  end


  describe "execution" do
    describe "of a bond bid" do
      before :each do
        @bond_bid = Factory.create(:bond_bid, :account => @buyer)
      end

      describe "that executes" do
        before :each do
          @bond_ask = Factory.create(:bond_ask, :account => @seller)
        end 

        it "creates trades called buys" do
          expect {
            @bond_bid.execute!
          }.to change(@bond_bid.buys, :count).by 1
          change(@bond_ask.sells, :count).by 1
        end

        it "marks itself and its trades' line_items as executed" do
          expect {
            @bond_bid.execute!
          }.to change(@bond_bid, :status).from("pending").to("executed")
          change(@bond_bid.buys.last.ask.reload, :status).from("pending").to("executed")
        end
      end

      describe "that pends" do
        it "does not create trades" do
          expect {
            @bond_bid.execute!
          }.not_to change(Trade, :count)
        end
        
        it "transfers funds from buyer to escrow" do
          expect {
            @bond_bid.execute!
          }.to change(@bond_bid.account.reload, :balance).by (-@bond_bid.max_bid_min_ask)
          change(@escrow.reload, :balance).by  @bond_bid.max_bid_min_ask
        end

        it "keeps its status as pending" do
          expect {
            @bond_bid.execute!
          }.not_to change(@bond_bid, :status).from("pending").to("executed")
        end
      end
    end

    describe "of a bond ask" do
      before :each do
        @seller.bonds.create(:qty => 5, :debtor => @treasury)
        @bond_ask = Factory.create(:bond_ask, :account => @seller, :qty => 5)
      end

      describe "that executes" do
        before :each do
          @bond_bid = Factory.create(:bond_bid, :account => @buyer, :qty => 5)
        end 

        it "creates trades called sells" do
          @bond_ask.execute!
          @bond_ask.sells.count.should eq 1
        end

         it "marks itself and its trades' line_items as executed" do
          expect {
            @bond_ask.execute!
          }.to change(@bond_ask, :status).from("pending").to("executed")
          change(@bond_ask.sells.last.bid.reload, :status).from("pending").to("executed")
        end
      end

      describe "that pends" do
        it "transfers bonds from seller to escrow" do
          @bond_ask.execute!
          @seller.reload.bonds.sum(:qty).should eq 0
          @escrow.reload.bonds.sum(:qty).should eq 5
        end

        it "does not create trades" do
          expect {
            @bond_ask.execute!
          }.not_to change(Trade, :count)
        end

        it "keeps its status as pending" do
          expect {
            @bond_ask.execute!
          }.not_to change(@bond_ask, :status).from("pending").to("executed")
        end

      end
    end

    describe "of a swap bid" do
      describe "at face value" do
        before :each do
          @swap_bid = Factory.create(:swap_bid, :account => @buyer,
                                     :max_bid_min_ask => @buyer.goal.face,
                                     :qty => 5)
        end
        describe "that executes" do
          #treasury should backfill line_items

          pending "creates trades called buys" do
            expect {
              @swap_bid.execute!
            }.to change(@swap_bid.buys, :count).by 1
            change(@swap_ask.sells, :count).by 1
          end

          pending "marks itself and its trades' line_items as executed" do
            expect {
              @swap_bid.execute!
            }.to change(@swap_bid, :status).from("pending").to("executed")
            change(@swap_bid.buys.last.ask.reload, :status).from("pending").to("executed")
          end

          pending "transfers funds from buyer to seller" do
            expect {
              @swap_bid.execute!
            }.to change(@swap_bid.account.reload, :balance).by (-@swap_bid.buys.last.total)
            change(@escrow.reload, :balance).by  @swap_bid.buys.last.total
          end

          pending "transfers swap from seller to buyer" do

          end
        end

        describe "that pends" do
          pending "does not create trades" do
            expect {
              @swap_bid.execute!
            }.not_to change(Trade, :count)
          end
          
          pending "doesn't transfer funds from buyer to escrow ?" do
            expect {
              @swap_bid.execute!
            }.not_to change(@swap_bid.account.reload, :balance).by (-@swap_bid.max_bid_min_ask)
            change(@escrow.reload, :balance).by  @swap_bid.max_bid_min_ask
          end

          pending "keeps its status as pending" do
            expect {
              @swap_bid.execute!
            }.not_to change(@swap_bid, :status).from("pending").to("executed")
          end
        end
      end

      describe "at less than face" do
        before :each do
          @swap_bid = Factory.create(:swap_bid, :account => @buyer)
        end
      end
    end

    describe "of a swap ask" do
      before :each do
        @seller.swaps.create(:qty => 5, :debtor => @treasury)
        @swap_ask = Factory.create(:swap_ask, :account => @seller, :qty => 5)
      end

      describe "that executes" do
        before :each do
          @swap_bid = Factory.create(:swap_bid, :account => @buyer, :qty => 5)
        end 

        pending "creates trades called sells" do
          @swap_ask.execute!
          @swap_ask.sells.count.should eq 1
        end

        pending "marks itself and its trades' line_items as executed" do
          expect {
            @swap_ask.execute!
          }.to change(@swap_ask, :status).from("pending").to("executed")
          change(@swap_ask.sells.last.bid.reload, :status).from("pending").to("executed")
        end
      end

      describe "that pends" do
        pending "transfers swaps from seller to escrow" do
          @swap_ask.execute!
          @seller.reload.swaps.sum(:qty).should eq 0
          @escrow.reload.swaps.sum(:qty).should eq 5
        end

        pending "does not create trades" do
          expect {
            @swap_ask.execute!
          }.not_to change(Trade, :count)
        end

        pending "keeps its status as pending" do
          expect {
            @swap_ask.execute!
          }.not_to change(@swap_ask, :status).from("pending").to("executed")
        end

      end
    end

    


  end

  describe "cancellation" do
    it "only cancels pending line_items" do
      l = Factory.create(:line_item, :account => @buyer)

      l.status = "executed"
      l.save!
      expect {
        l.cancel!
      }.not_to change(l, :status)

      l.status = "new"
      l.save!
      expect {
        l.cancel!
      }.not_to change(l, :status)

      l.status = "pending"
      l.save!
      expect {
        l.cancel!
      }.to change(l, :status).to "cancelled"
    end

    pending "returns cash and such" do
      
    end

  end
end
