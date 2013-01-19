require 'spec_helper'

describe Account do
  before do
    @user = Factory.create(:user)
    @goal = Factory.create(:goal)
    @user.follow_goal(@goal)
    @buyer  = @user.accounts.last
    @treasury = Factory.create(:account, :is_treasury => true)
    @goal.accounts << @treasury
  end
  
  describe "has many" do
    describe "orders through user and" do
      it "responds to orders" do
        o = Factory.create(:order)
        @user.orders << o
        @buyer.should respond_to(:orders)
        @buyer.orders.should eq @user.orders
      end
    end

    describe "bonds and" do
      it "responds to bonds" do
        a = Factory.create(:account)
        a.should respond_to(:bonds)
      end
    end

    describe "swaps and" do
      it "responds to swaps" do
        a = Factory.create(:account)
        a.should respond_to(:swaps)
      end
    end

    describe "line_items and" do
      it "responds to line_items" do
        @buyer.should respond_to(:line_items)
        li = @buyer.line_items.create!(:qty => 1, :type_of => "bond bid")
        @buyer.line_items.last.should eq li
      end
    end
  end

  describe "belongs to" do
    describe "its user and" do
      it "responds to user" do
        a = Factory.create(:account)
        a.should respond_to(:user)
      end
    end

    describe "its goal and" do
      it "responds to goal" do
        a = Factory.create(:account)
        a.should respond_to(:goal)
      end
    end
  end  

  it "should have an initial balance of zero" do
    a = Account.create!
    a.balance.should eq 0.0
  end

  describe "transfer_bond_to!" do
    describe "called by treasury" do
      it "creates a bond for buyer and a swap for treasury" do
        @treasury.swaps.count.should eq 0
        @buyer.bonds.count.should eq 0
        @treasury.transfer_bond_to!(@buyer)
        @buyer.bonds.count.should eq 1
        @treasury.swaps.count.should eq 1
      end

      it "increases treasury swap qty" do
        @treasury.swaps.sum(:qty).should eq 0
        @buyer.bonds.sum(:qty).should eq 0
        @treasury.transfer_bond_to!(@buyer)
        @treasury.swaps.sum(:qty).should eq 1
        @buyer.bonds.sum(:qty).should eq 1
      end

      it "increases treasury swap count and buyer bond count only if unique" do
        @treasury.transfer_bond_to!(@buyer)
        @buyer.bonds.count.should eq 1
        @treasury.swaps.count.should eq 1
        @buyer.bonds.first.qty.should eq 1
        @treasury.swaps.first.qty.should eq 1

        @treasury.transfer_bond_to!(@buyer)
        @buyer.bonds.count.should eq 1
        @treasury.swaps.count.should eq 1
        @buyer.bonds.last.qty.should eq 2
        @treasury.swaps.last.qty.should eq 2
      end
    end

    describe "called by reg account" do
      before :each do
        @untreasury = @goal.accounts.create!(:is_treasury => false, :balance => 0.0)
        @debtor = @goal.accounts.create!
      end

      describe "with no bonds to sell" do
        it "doesn't create a new bond" do
          expect {
            @untreasury.transfer_bond_to!(@buyer)  
          }.to_not change(@buyer.bonds, :count)
          @untreasury.swaps.count.should eq 0
          @buyer.bonds.sum(:qty).should eq 0
          @untreasury.swaps.sum(:qty).should eq 0
        end
      end

      describe "with a bond to sell" do
        describe "having qty > 1" do
          before :each do
            @untreasury.bonds.create!(:debtor => @debtor, :qty => 10)
          end

          it "doesn't create swaps for itself" do
            @untreasury.transfer_bond_to!(@buyer)  
            @untreasury.swaps.empty?.should be true
          end

          it "doesn't change debtor swap qty" do
            @debtor.swaps.sum(:qty).should eq 10
            @untreasury.transfer_bond_to!(@buyer)
            @debtor.swaps.sum(:qty).should eq 10
          end

          it "does change debtor swap count" do
            @debtor.swaps.count.should eq 1
            @untreasury.transfer_bond_to!(@buyer)
            @debtor.swaps.count.should eq 2
          end

          it "decrements its sellable bond by 1" do
            @untreasury.transfer_bond_to!(@buyer)
            @untreasury.bonds.first.qty.should eq 9
          end

          it "increases its buyers bond qty by 1" do
            @buyer.bonds.sum(:qty).should eq 0
            @untreasury.transfer_bond_to!(@buyer)
            @buyer.bonds.sum(:qty).should eq 1
          end

          it "increases bond count of buyer by 1 if unique" do 
            @buyer.bonds.count.should eq 0
            @treasury.transfer_bond_to!(@buyer) #buyer has a bond
            @buyer.bonds.count.should eq 1
            @untreasury.transfer_bond_to!(@buyer)
            @buyer.bonds.count.should eq 2
          end

          it "doesn't increase bond count of buyer if not unique" do
            @buyer.bonds.count.should eq 0
            @untreasury.transfer_bond_to!(@buyer)
            @buyer.bonds.count.should eq 1
            @untreasury.transfer_bond_to!(@buyer)
            @buyer.bonds.count.should eq 1
          end          
        end

        describe "having qty 1" do
          before :each do
            @untreasury.bonds.create!(:debtor => @debtor, :qty => 1)
          end

          it "doesn't create swaps for itself" do
            @untreasury.transfer_bond_to!(@buyer)  
            @untreasury.swaps.empty?.should be true
          end

          it "doesn't change debtor swap qty" do
            @debtor.swaps.sum(:qty).should eq 1
            @untreasury.transfer_bond_to!(@buyer)
            @debtor.swaps.sum(:qty).should eq 1
          end

          it "doesn't change debtor swap count" do
            @debtor.swaps.count.should eq 1
            @untreasury.transfer_bond_to!(@buyer)
            @debtor.swaps.count.should eq 1
          end

          it "transfers its sellable bond to buyer" do
            @untreasury.bonds.first.qty.should eq 1
            @untreasury.bonds.count.should eq 1
            @untreasury.transfer_bond_to!(@buyer)
            @untreasury.bonds.count.should eq 0
            @buyer.bonds.count.should eq 1
          end

          it "increases its buyers bond qty by 1" do
            @buyer.bonds.sum(:qty).should eq 0
            @untreasury.transfer_bond_to!(@buyer)
            @buyer.bonds.sum(:qty).should eq 1
          end

          it "increases bond count of buyer by 1 if unique" do 
            @buyer.bonds.count.should eq 0
            @treasury.transfer_bond_to!(@buyer) #buyer has a bond
            @buyer.bonds.count.should eq 1
            @untreasury.transfer_bond_to!(@buyer)
            @buyer.bonds.count.should eq 2
          end

          it "doesn't increase bond count of buyer if not unique" do
            @buyer.bonds.count.should eq 0
            @buyer.bonds.create(:debtor => @debtor, :qty => 1)
            @buyer.bonds.count.should eq 1
            @untreasury.transfer_bond_to!(@buyer)
            @buyer.bonds.count.should eq 1
          end        

        end
      end
    end
  end

  describe "the treasury" do
    it "can have line_items that do not have an order" do
      bid = Factory.create(:bid)
      @treasury.line_items << bid
      @treasury.reload.line_items.first.should eq bid
    end

    it "does not have a user" do
      @treasury.user.should be_nil
    end 
  end

  describe "A regular account" do
    before :each do
        @untreasury = @goal.accounts.create!(:is_treasury => false, :balance => 0.0)
    end

    describe "can't be destroyed if it has" do
      it "at least one bond" do
        @untreasury.bonds.create!
        expect {
          @untreasury.destroy
        }.to change(Account, :count).by(0)
        expect {
          @untreasury.destroy
        }.to change(Bond, :count).by(0)
      end

      it "at least one swap" do
        @untreasury.swaps.create!
        expect {
          @untreasury.destroy
        }.to change(Account, :count).by(0)
        expect {
          @untreasury.destroy
        }.to change(@untreasury.swaps, :count).by(0)
      end

      it "at least one pending line_item" do
        @untreasury.line_items.create!(:qty => 1, :status => "pending")
        expect {
          @untreasury.destroy
        }.to change(Account, :count).by(0)
        expect {
          @untreasury.destroy
        }.to change(Order, :count).by(0)        
      end
    end
  end
end
