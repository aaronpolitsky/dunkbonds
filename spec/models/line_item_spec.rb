require 'spec_helper'

describe LineItem do
  before :each do
    @user = Factory.create(:user)
    @user2 = Factory.create(:asdf)
    @goal = Factory.create(:goal)
    @account = @user.accounts.last
    @face = @goal.bond_face_value
    @user.follow_goal @goal
    @user2.follow_goal @goal
    @buyer = @user.accounts.last
    @seller = @user2.accounts.last
    @escrow   = @goal.escrow
    @treasury = @goal.treasury
  end
  
  describe "belongs to" do
    
    describe "stuff and" do
      it "responds to stuff" do
        l = @buyer.line_items.create!(:qty => 1,
                                      :max_bid_min_ask => 10)
        l.should respond_to(:cart)
        l.should respond_to(:order)
        l.should respond_to(:account) 
        l.should respond_to(:parent)
        l.should respond_to(:child)
        l.reload.account.should eq @buyer     
      end
    end
  end  

  describe "can have" do
    it "one cancellation" do
      l = @buyer.line_items.create!(:qty => 1,
                                    :max_bid_min_ask => 10)
      l.should respond_to :cancellation
    end

    describe "many trades" do
      it "and responds to buys" do
        l = @buyer.line_items.create!(:qty => 1,
                                      :max_bid_min_ask => 10)
        l.should respond_to(:buys)   
      end
      
      it "and responds to sells" do
        l = @buyer.line_items.create!(:qty => 1,
                                      :max_bid_min_ask => 10)
        l.should respond_to(:sells)   
      end
    end 
  end

  describe "updating" do
    it "a new swap bid qty updates its child qty automatically" do
      swap = @seller.line_items.create!(:type_of => "swap bid",
                                        :qty => 1,
                                        :max_bid_min_ask => @goal.bond_face_value)
      swap.update_attributes!(:qty => 2)
      swap.child.reload.qty.should eq swap.qty
    end

    it "a new swap bond ask's qty updates its swap qty automatically " do
      swap = @seller.line_items.create!(:type_of => "swap bid",
                                        :qty => 1,
                                        :max_bid_min_ask => @goal.bond_face_value)
      child = swap.child
      child.qty = 2
      child.save!
      swap.reload.qty.should eq child.qty
    end
  end

  describe "must" do #validations
    it "have a valid quantity" do
      @buyer.line_items.new(:max_bid_min_ask => 10, :qty => 0).should_not be_valid
      @buyer.line_items.new(:max_bid_min_ask => 10, :qty => -1).should_not be_valid
      @buyer.line_items.new(:max_bid_min_ask => 10, :qty => 101).should_not be_valid
      @buyer.line_items.new(:max_bid_min_ask => 10, :qty => 100).should be_valid
    end

    it "have an account" do
      LineItem.new(:max_bid_min_ask => 10, :qty => 100).should_not be_valid
    end

    it "not be able to sell bonds it does not have, unless it is linked to a swap" do
      @buyer.bonds.count.should eq 0
      @buyer.line_items.new(:type_of => "bond ask",
                            :max_bid_min_ask => 10,
                            :qty => 10).should_not be_valid
      swapbid = @buyer.line_items.create!(:type_of => "swap bid",
                            :max_bid_min_ask => 10,
                            :qty => 10)
      swapbid.child.should be_valid
    end

    it "not be valid if the cart's qty of bond asks would exceed the account's bond qty." do
      # pending "this might be better checked before order creation"
      cart = @user.cart
      @buyer.bonds.create!(:debtor => @treasury, :qty => 5)
      @buyer.line_items.create!(:type_of => "bond ask",
                                :max_bid_min_ask => 10,
                                :qty => 4)
      cart.line_items << @buyer.line_items.last
      @buyer.line_items.new(:type_of => "bond ask",
                            :max_bid_min_ask => 10,
                            :qty => 2).should_not be_valid
      @buyer.line_items.new(:type_of => "bond ask",
                            :max_bid_min_ask => 10,
                            :qty => 1).should be_valid
      swapbid = @buyer.line_items.create!(:type_of => "swap bid",
                            :max_bid_min_ask => 10,
                            :qty => 1)
      swapbid.child.should be_valid
    end

    it "belong to either a cart or an order" do
      pending "not sure about this"
      @buyer.line_items.new(:type_of => "bond bid",
                            :max_bid_min_ask => 4,
                            :qty => 10).should_not be_valid
      @buyer.line_items.new(:type_of => "bond bid",
                            :max_bid_min_ask => 4,
                            :cart_id => 1,
                            :qty => 10).should be_valid
      @buyer.line_items.new(:type_of => "bond bid",
                            :max_bid_min_ask => 4,
                            :order_id => 1,
                            :qty => 10).should be_valid
      @buyer.line_items.new(:type_of => "bond bid",
                            :max_bid_min_ask => 4,
                            :cart_id => 1,
                            :order_id => 1,
                            :qty => 10).should_not be_valid
    end

    it "have an initial status of new" do
      l = @buyer.line_items.create!(:qty => 1,
                                    :max_bid_min_ask => 10)
      l.status.should eq "new"
    end

    it "creation of a swap bid should create its child bond ask" do
      swap_bid = @seller.line_items.new(:type_of => "swap bid",
                                        :qty => 5,
                                        :max_bid_min_ask => @face)
      expect { swap_bid.save! }.to change(LineItem, :count).by 2

      swap_bid.child.should eq LineItem.last
      swap_bid.child.parent.should eq swap_bid
      swap_bid.child.type_of.should eq "bond ask"
      swap_bid.child.qty.should eq swap_bid.qty
    end
  end

  describe "swap bids must" do
    it "bid at least face value" do
      swap_bid = @seller.line_items.new(:type_of => "swap bid",
                                        :qty => 5,
                                        :max_bid_min_ask => @face/2)
      swap_bid.should_not be_valid
    end
  end

  describe "line_items having a parent must" do #validations
    before :each do
      @swap_bid = @seller.line_items.create!(:type_of => "swap bid",
                                             :qty => 5,
                                             :max_bid_min_ask => @face)
      @child = @swap_bid.child
    end
    
    it "be bond asks"  do 
      @child.type_of = "bond bid"
      @child.should_not be_valid
      @child.type_of = "swap bid"      
      @child.should_not be_valid
      @child.type_of = "swap ask"      
      @child.should_not be_valid
    end

    xit "inherit qty from parent" do
      @child.qty = @swap_bid.qty-1
      @child.should_not be_valid      
      @child.qty = @swap_bid.qty+1      
      @child.should_not be_valid      
    end

  end


  describe "find_matching_bond_asks" do

    describe "when bidding less than face" do
      before :each do
        @bidding = @goal.bond_face_value/2
        t = Time.now
        @bond_bid = @buyer.line_items.create!(:type_of => "bond bid",
                                              :qty => 5, 
                                              :max_bid_min_ask => @bidding)
        @seller.bonds.create!(:debtor => @treasury, :qty => 8)
        @pricey1 = @seller.line_items.create!(:type_of => "bond ask",
                                           :qty => 2, 
                                           :max_bid_min_ask => @bidding+1,
                                           :status => "pending")
        @swap_bid = @seller.line_items.create!(:type_of => "swap bid",
                                              :qty => 1,
                                              :max_bid_min_ask => @goal.bond_face_value, 
                                              :status => "pending")
        @swap_bond_ask = @swap_bid.child
        @swap_bond_ask.max_bid_min_ask = @bidding
        @swap_bond_ask.status = "pending"
        @swap_bond_ask.save!

        @used_bond_ask2 = @seller.line_items.create!(:type_of => "bond ask",
                                           :qty => 1, 
                                           :created_at => t,
                                           :max_bid_min_ask => @bidding,
                                           :status => "pending")
        @used_bond_ask3 = @seller.line_items.create!(:type_of => "bond ask",
                                           :qty => 2, 
                                           :created_at => t,
                                           :max_bid_min_ask => @bidding,
                                           :status => "pending")
        @used_bond_ask4 = @seller.line_items.create!(:type_of => "bond ask",
                                           :qty => 1, 
                                           :created_at => t + 1.hour,
                                           :max_bid_min_ask => @bidding-1,
                                           :status => "pending")
        @used_bond_ask5 = @seller.line_items.create!(:type_of => "bond ask",
                                           :qty => 1, 
                                           :created_at => t + 2.hour,
                                           :max_bid_min_ask => @bidding-1,
                                           :status => "pending")
      end
      
      describe "for a bondholder" do
        before :each do
          @buyer.bonds.create!(:debtor => @treasury, :qty => 1)
        end
        
        describe "includes" do
          it "all asks < bidding" do
            matches = @bond_bid.find_matching_bond_asks
            matches.should include @swap_bond_ask
            matches.should include @used_bond_ask2
            matches.should include @used_bond_ask3
            matches.should include @used_bond_ask4
          end
        end

        describe "excludes" do
          it "asks >= bidding" do
            matches = @bond_bid.find_matching_bond_asks
            matches.should_not include @pricey1
            matches.should_not include @used_bond_ask5
          end
        end
        
        describe "orders matches by" do
          it "time then price" do
            matches = @bond_bid.find_matching_bond_asks
            matches[0].should eq @swap_bond_ask
            matches[1].should eq @used_bond_ask2
            matches[2].should eq @used_bond_ask3
            matches[3].should eq @used_bond_ask4
            matches.inject(0){|sum, e| sum += e.qty}.should eq @bond_bid.qty
          end
        end
      end

      describe "for a non-bondholder" do
        it "only includes swap asks < bidding" do
          @bond_bid.qty = 2
          @bond_bid.save!
          matches = @bond_bid.find_matching_bond_asks
          matches.should eq [] #:reason => "because there aren't enough matches if you leave out the used bond asks."
        end

        it "excludes used bond asks" do
          @bond_bid.qty = 2
          @bond_bid.save!
          @swap_bond_ask.destroy
          matches = @bond_bid.find_matching_bond_asks
          matches.should eq []
        end

      end
    end


    describe "when bidding face value" do
      before :each do
        @bidding = @goal.bond_face_value
        t = Time.now
        @bond_bid = @buyer.line_items.create!(:type_of => "bond bid",
                                              :qty => 5, 
                                              :max_bid_min_ask => @bidding)
      end
      
      describe "when no other matches exist" do
        it "the treasury creates a matching ask" do
          @bond_bid.find_matching_bond_asks.should include @treasury.line_items.last
          @bond_bid.find_matching_bond_asks.first.qty.should eq @bond_bid.qty
        end
      end

      describe "when a pending swap_bid exists" do
        before :each do
          @swap_bid = @seller.line_items.create!(:type_of => "swap bid",
                                                :qty => 3,
                                                :max_bid_min_ask => @goal.bond_face_value, 
                                                :status => "pending")
          @good1 = @swap_bid.child
          @good1.max_bid_min_ask = @bidding
          @good1.status = "pending"
          @good1.save!
        end
        
        it "matches include all swaps then backfills with the T asks" do
          matches = @bond_bid.find_matching_bond_asks
          matches.should include @treasury.line_items.last
          @treasury.line_items.last.qty.should eq 2
          matches.should include @good1
          
          @swap_bid.qty = @good1.qty = 5
          @swap_bid.save!
          @good1.parent.reload
          @good1.save!
          matches = @bond_bid.find_matching_bond_asks
          matches.should include @good1
          matches.should_not include @treasury.line_items.last
        end

        it "matches prioritize the swap-bond ask over treasury asks" do
          matches = @bond_bid.find_matching_bond_asks
          matches[0].should eq @good1
          matches[1].should eq @treasury.line_items.last
        end

      end

    end 
    
    describe "for qty 1" do
      it "should find the earliest best bond ask" do
        @seller.bonds.create!(:debtor => @treasury, :qty => 1)
        bestask = Factory.create(:bond_ask, :status => "pending", :account => @seller, :max_bid_min_ask => @face-2, :created_at => Time.now)
        laterask = Factory.create(:bond_ask, :status => "pending", :account => @seller, :max_bid_min_ask => @face-2, :created_at => bestask.created_at + 1.hour)
        priceyask = Factory.create(:bond_ask, :status => "pending", :account => @seller, :max_bid_min_ask => @face-1, :created_at => bestask.created_at)
        @buyer.bonds.create!(:debtor => @treasury, :qty => 1)
        bid = Factory.create(:bond_bid, :max_bid_min_ask => @face-1, :account => @buyer)
        matches = bid.find_matching_bond_asks
        matches.should eq [bestask]
        matches.should_not eq [priceyask]
        matches.should_not eq [laterask]
      end
    end
    
    describe "for qty n > 1" do
      it "should return [] if < n matching asks exist" do
        @seller.bonds.create!(:debtor => @treasury, :qty => 1)
        @buyer.bonds.create!(:debtor => @treasury, :qty => 1)
        ask = Factory.create(:bond_ask, :max_bid_min_ask => @face-2, :qty => 1, :status => "pending", :account => @seller)
        bid = Factory.create(:bond_bid, :max_bid_min_ask => @face-2, :qty => 2, :account => @buyer)
        bid.find_matching_bond_asks.should eq []
      end
      
      it "should ignore any potential match that is of greater qty than required" do
        @buyer.bonds.create!(:debtor => @treasury, :qty => 1)
        bid = Factory.create(:bond_bid, :max_bid_min_ask => @face-2, :qty => 2, :account => @buyer)
        @seller.bonds.create!(:debtor_id => @treasury, :qty => 5)
        ask3 = @seller.line_items.create!(:type_of => "bond ask", 
                                         :max_bid_min_ask => @face-2, 
                                         :qty => 3, 
                                         :status => "pending")
        ask2 = @seller.line_items.create!(:type_of => "bond ask", 
                                         :max_bid_min_ask => @face-2, 
                                         :qty => 2, 
                                         :status => "pending")
        matches = bid.find_matching_bond_asks
        matches.should_not include ask3
        matches.should include ask2
      end
      
      describe "should find n of the earliest best asks" do
        it "even if from > 1 matches" do
          @buyer.bonds.create!(:debtor => @treasury, :qty => 1)
          bid = Factory.create(:bond_bid, :max_bid_min_ask => @face-2, :qty => 2, :account => @buyer)
          best_asks = []
          @seller.bonds.create!(:debtor => @treasury, :qty => 3)
          3.times  { best_asks << Factory.create(:bond_ask, :max_bid_min_ask => @face-2, :status => "pending", :account => @seller) }
          matches = bid.find_matching_bond_asks
          matches.should eq best_asks[0..1]
          matches.should_not eq best_asks
        end
      end
    end
  end

  describe "find_matching_bond_bids" do
    describe "when asking face" do 
      before :each do
        @seller.bonds.create!(:debtor_id => @treasury, :qty => 5)
        
        @bond_ask = @seller.line_items.create!(:type_of => "bond ask",
                                              :qty => 5, 
                                              :max_bid_min_ask => @goal.bond_face_value)
      end

      it "only matches if it has a parent swap" do
        bb = @buyer.line_items.create!(:type_of => "bond bid",
                                       :qty => 5,
                                       :max_bid_min_ask => @bond_ask.max_bid_min_ask,
                                       :status => "pending")
        @bond_ask.find_matching_bond_bids.should eq []        
      end      
    end
    describe "when asking less than face" do
      before :each do
        @asking = @goal.bond_face_value/2
        t = Time.now
        @seller.bonds.create!(:debtor => @treasury, :qty => 5)
        @bond_ask = @seller.line_items.create!(:type_of => "bond ask",
                                              :qty => 5, 
                                              :max_bid_min_ask => @asking)
        @bad1 = @buyer.line_items.create!(:type_of => "bond bid",
                                           :qty => 2, 
                                           :max_bid_min_ask => @asking-1,
                                           :status => "pending")
        @good1 = @buyer.line_items.create!(:type_of => "bond bid",
                                           :qty => 2, 
                                           :created_at => t,
                                           :max_bid_min_ask => @asking+1,
                                           :status => "pending")
        @good2 = @buyer.line_items.create!(:type_of => "bond bid",
                                           :qty => 2, 
                                           :created_at => t,
                                           :max_bid_min_ask => @asking,
                                           :status => "pending")
        @good3 = @buyer.line_items.create!(:type_of => "bond bid",
                                           :qty => 1, 
                                           :created_at => t + 1.hour,
                                           :max_bid_min_ask => @asking,
                                           :status => "pending")
      end
      
      describe "includes" do
        it "bids >= asking" do
          @matches = @bond_ask.find_matching_bond_bids
          @matches.should include @good1
          @matches.should include @good2
          @matches.should include @good3
        end
      end
      describe "excludes" do
        it "bids < asking" do
          @matches = @bond_ask.find_matching_bond_bids
          @matches.should_not include @bad1
        end
      end
      describe "orders matches by" do
        it "time then price" do
          @matches = @bond_ask.find_matching_bond_bids
          @matches[0].should eq @good1
          @matches[1].should eq @good2
          @matches[2].should eq @good3
        end
      end
    end
  end

  describe "attempted execution" do
    describe "of a bond bid" do
      before :each do
        @buyer.bonds.create!(:debtor => @treasury, :qty => 1)
        @bond_bid = @buyer.line_items.create!(:type_of => "bond bid",
                                              :qty => 1,
                                              :max_bid_min_ask => @face/2)
      end

      describe "that executes" do
        before :each do
          @seller.bonds.create!(:debtor => @treasury, :qty => 1)
          @bond_ask = Factory.create(:bond_ask, :account => @seller,
                                     :max_bid_min_ask => @face/2)
          @bond_ask.execute!
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
          }.to change(@bond_bid, :status).to("executed")
          change(@bond_bid.buys.last.ask.reload, :status).to("executed")
        end

        it "executes its matches parent swap, if exists" do
          swap = @seller.line_items.create!(:type_of => "swap bid",
                                            :qty => 1,
                                            :max_bid_min_ask => @face)
          bond_ask = swap.child
          bond_ask.max_bid_min_ask = @face/2
          bond_ask.save!
          swap.execute!
          @bond_bid.execute!
          @bond_bid.buys.last.ask.reload.status.should eq "executed"
          @bond_bid.buys.last.ask.parent.reload.status.should eq "executed"

        end
      end

      describe "that pends" do
        it "does not create trades" do
          expect {
            @bond_bid.execute!
          }.not_to change(Trade, :count)
        end
        
        it "transfers bid $amount from buyer to escrow" do
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


    describe "of a used bond ask" do
      before :each do
        @seller.bonds.create(:qty => 5, :debtor => @treasury)

        @bond_ask = @seller.line_items.create!(:type_of => "bond ask",
                                               :qty => 5,
                                               :max_bid_min_ask => @face/2)
      end

      describe "that executes" do
        before :each do
          @bond_bid = @buyer.line_items.create!(:type_of => "bond bid",
                                                :qty => 5,
                                                :max_bid_min_ask => @face/2)
          @bond_bid.execute!
        end 

        it "creates trades called sells" do
          @bond_ask.execute!
          @bond_ask.sells.count.should eq 1
        end

        it "marks itself and its trades' line_items as executed" do
          expect {
            @bond_ask.execute!
          }.to change(@bond_ask, :status).to("executed")
          change(@bond_ask.sells.last.bid.reload, :status).to("executed")
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

    describe "of a swap-based bond ask" do
      before :each do
        @swap_bid = Factory.create(:swap_bid, 
                                   :account => @seller,
                                   :qty => 5)
       
        # above should create bond ask
        @bond_ask = @swap_bid.child
      end

      it "creates a treasury swap ask and executes its parent swap " do
        expect {
          @bond_ask.execute!
        }
      end
    end

    describe "of a swap bid" do
      before :each do
        @swap_bid = @buyer.line_items.create!(:type_of => "swap bid",
                                              :account => @buyer,
                                              :max_bid_min_ask => @buyer.goal.bond_face_value,
                                              :qty => 5)
      end
      describe "that executes" do
        #treasury should backfill line_items, so no line item creation here.


        before :each do
          @swap_bid.child.status = 'executed'
          @swap_bid.child.save!
        end

        it "must have an executed child bond ask before it executes" do
          @swap_bid.child.status = "pending"
          @swap_bid.child.save!
          expect {
            @swap_bid.execute!
          }.to change(@swap_bid, :status).from("new").to("pending")
          @swap_bid.child.status = 'executed'
          @swap_bid.child.save!
          expect {
            @swap_bid.execute!
          }.to change(@swap_bid, :status).to("executed")
        end


        it "creates one buy trade linking an ask from the treasury" do
          expect {
            @swap_bid.execute!
          }.to change(@swap_bid.buys, :count).by 1
          change(Trade, :count).by 1
          @swap_bid.buys.last.ask.account.should eq @treasury
          @swap_bid.buys.last.ask.qty.should eq @swap_bid.qty
        end

        it "marks itself and its trades' line_items as executed" do
          expect {
            @swap_bid.execute!
          }.to change(@swap_bid, :status).from("new").to("executed")
          change(@swap_bid.buys.last.ask.reload, :status).from("pending").to("executed")
        end

        it "transfers funds from buyer to seller" do
#          expect {
          @swap_bid.execute!
#         }.to change(@swap_bid.account.reload, :balance).by (-@swap_bid.buys.last.total)
#         change(@treasury.reload, :balance).by  @swap_bid.buys.last.total
          @swap_bid.account.reload.balance.should eq -@swap_bid.buys.last.total
        end

        it "transfer swaps from treasury to buyer if swap was new"  do
#          expect {
            @swap_bid.status.should eq "new"
            @swap_bid.account.swap_qty.should eq 0
            @swap_bid.execute!
            @swap_bid.status.should eq "executed"
            @swap_bid.account.swap_qty.should eq 5
 #         }.to change(@swap_bid.account.reload, :swap_qty).by (@swap_bid.qty)
  #        change(@swap_bid, :status).from("new").to("executed")
        end
      end

      describe "that pends" do
        it "does not create trades" do
          expect {
            @swap_bid.execute!
          }.not_to change(@swap_bid.reload.buys, :count)
        end
        
        it "grants swaps to the buyer and bonds to escrow" do
#          expect {
          @swap_bid.execute!
 #         }.to change(@buyer.reload, :swap_qty).by (@swap_bid.qty)
#          change(@escrow.reload, :bond_qty).by @swap_bid.qty
          @buyer.swap_qty.should eq @swap_bid.qty
          @escrow.bond_qty.should eq @swap_bid.qty
        end

        it "doesn't transfer any funds" do
          expect {
            @swap_bid.execute!
          }.not_to change(@swap_bid.account.reload, :balance)
          change(@escrow.reload, :balance)
          change(@treasury.reload, :balance)
        end

        it "keeps its status as pending" do
          expect {
            @swap_bid.execute!
          }.not_to change(@swap_bid, :status).from("pending")
        end
      end
    end

  end

  describe "cancellation" do
    it "only cancels pending line_items" do
      l = @buyer.line_items.create!(:type_of => "bond bid",
                                    :qty => 1,
                                    :max_bid_min_ask => @goal.bond_face_value-2)

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

    describe "of a swap bid" do
      before :each do
        @swap_bid = @seller.line_items.create!(:type_of => "swap bid",
                                               :qty => 7,
                                               :max_bid_min_ask => @goal.bond_face_value)
        @swap_bid.execute!
      end

      it "decrements its account's swaps by qty and cancels its child and itself" do
        @swap_bid.cancel!
        @swap_bid.status.should eq "cancelled"
        @swap_bid.child.status.should eq "cancelled"
        @seller.swap_qty.should eq 0
        Bond.count.should eq 0
      end

      it "creates its and its child's cancellation" do
        expect {
          @swap_bid.cancel!
        }.to change(Cancellation, :count).by 2
        @swap_bid.cancellation.should eq Cancellation.first
        @swap_bid.child.cancellation.should eq Cancellation.last
      end 

      it "only destroys qty swaps if more than a few exist" do
        other_swap_bid = @seller.line_items.create!(:type_of => "swap bid",
                                               :qty => 4,
                                               :max_bid_min_ask => @goal.bond_face_value)
        other_swap_bid.execute!
        other_swap_bid.cancel!
        other_swap_bid.status.should eq "cancelled"
        other_swap_bid.child.status.should eq "cancelled"
        other_swap_bid.account.swap_qty.should eq 7
        @swap_bid.status.should eq "pending"
        @swap_bid.child.status.should eq "pending"
        @escrow.bond_qty.should eq 7
      end
    end

    describe "of a bond ask" do

      describe "that has a parent swap" do
        before :each do
          @swap_bid = @seller.line_items.create!(:type_of => "swap bid",
                                                 :qty => 7,
                                                 :max_bid_min_ask => @goal.bond_face_value)
          @bond_ask = @swap_bid.child
          @bond_ask.max_bid_min_ask = @goal.bond_face_value/2
          @bond_ask.save!
          @swap_bid.execute!
        end

        it "cancels its parent swap as well" do
          @bond_ask.cancel!
          @bond_ask.reload.status.should eq "cancelled"
          @swap_bid.reload.status.should eq "cancelled"
        end

        it "gets its bonds back from escrow" do
          @escrow.bond_qty.should eq 7
          @bond_ask.cancel!
          @escrow.reload.bond_qty.should eq 0
        end
      end

      describe "that does not have a parent swap" do
        before :each do
          @seller.bonds.create!(:debtor => @treasury, :qty => 10)
          @bond_ask = @seller.line_items.create!(:type_of => "bond ask",
                                                 :qty => 7,
                                                 :max_bid_min_ask => @goal.bond_face_value/2)
          @bond_ask.execute!
        end

        it "cancels itself and creates its cancellation" do
          @bond_ask.cancel!
          @bond_ask.reload.status.should eq "cancelled"
          @seller.reload.bond_qty.should eq 10
          @bond_ask.cancellation.should eq Cancellation.last
        end

        it "removes its bonds from escrow" do
          @seller.bond_qty.should eq 3
          @escrow.bond_qty.should eq 7
          @bond_ask.cancel!
          @seller.reload.bond_qty.should eq 10
          @escrow.bond_qty.should eq 0
        end
                
      end
    end

    describe "of a bond bid" do
      describe "that is pending" do
        before :each do
          @bond_bid = @buyer.line_items.create!(:type_of => "bond bid",
                                                 :qty => 7,
                                                 :max_bid_min_ask => @goal.bond_face_value-1)
          @bond_bid.execute!
        end

        it "creates its cancellation" do
          expect {
            @bond_bid.cancel!
          }.to change(Cancellation, :count).by 1
          @bond_bid.cancellation.should eq Cancellation.last
        end 

        it "gets its money back from escrow" do
          @escrow.reload.balance.should eq 63
          @buyer.reload.balance.should eq -63
          expect {
            @bond_bid.cancel!
          }.to change(@bond_bid, :status).from("pending").to("cancelled")
          @escrow.reload.balance.should eq 0
          @buyer.reload.balance.should eq 0
        end
      end
    end

  end
end


