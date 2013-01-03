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

    describe "line_items" do
      it "responds to line_items" do
        o = @user.orders.create!
        li = Factory.create(:line_item, :goal => @goal)
        o.line_items << li
        @buyer.should respond_to(:line_items)
      end

      it "yields only its goal's line_items" do
        o = @user.orders.create!
        li = Factory.create(:line_item, :goal => @goal)
        li2 = Factory.create(:line_item, :goal => Factory.create(:goal))
        o.line_items << li
        o.line_items << li2
        @buyer.line_items.should eq([li])
        @buyer.line_items.should_not eq([li2])
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

  it "the first bond between accounts should create a new bond row" do
    @treasury.sell_bond!(@buyer)
    @buyer.bonds.count.should eq 1
    @treasury.swaps.count.should eq 1
    @buyer.bonds.first.qty.should eq 1
    @treasury.swaps.first.qty.should eq 1
  end
  
  it "the second bond between accounts should increment bond quantity rather than create a new bond row" do
    @treasury.sell_bond!(@buyer)
    @treasury.sell_bond!(@buyer)
    @buyer.bonds.count.should eq 1
    @treasury.swaps.count.should eq 1
    @buyer.bonds.first.qty.should eq 2
    @treasury.swaps.first.qty.should eq 2
  end
  
  describe "A regular account" do
    before :each do
      @untreasury = @goal.accounts.create!(:is_treasury => false, :balance => 0.0)
    end

    describe "can't be destroyed if it has" do
      it "at least one bond" do
        @untreasury.bonds << Bond.create!
        expect {
          @untreasury.destroy
        }.to change(Account, :count).by(0)
        expect {
          @untreasury.destroy
        }.to change(Bond, :count).by(0)
      end

      it "at least one swap" do
        @untreasury.swaps << Bond.create!
        expect {
          @untreasury.destroy
        }.to change(Account, :count).by(0)
        expect {
          @untreasury.destroy
        }.to change(@untreasury.swaps, :count).by(0)
      end

      pending "at least one pending line_item" do
        expect {
          @untreasury.destroy
        }.to change(Account, :count).by(0)
        expect {
          @untreasury.destroy
        }.to change(Order, :count).by(0)        
      end
    end

    describe "having no bonds cannot" do

      it "create a bond from thin air" do
        expect {
          @untreasury.sell_bond!(@buyer)
        }.to_not change {Bond.count}
        @untreasury.swaps.count.should eq 0
      end
      
      it "sell a bond" do
        expect {
          @untreasury.sell_bond!(@buyer)
        }.to_not change {@buyer.bonds.sum(:qty)}
      end  

    end

    describe "having one bond" do
      before :each do
        @treasury.sell_bond!(@untreasury)
      end
      
      it "can sell a bond" do
        expect {
          @untreasury.sell_bond!(@buyer)
        }.to change {@buyer.bonds.sum(:qty)}.by(1)
        assert_equal 0, @untreasury.bonds.where(:goal_id => @goal).sum(:qty)
      end

    end
    
    describe "having more than one bond" do
      before :each do
        @treasury.sell_bond!(@untreasury)
        @treasury.sell_bond!(@untreasury)
      end
      
      it "when selling a bond decrements its bond qty" do
        expect {
          @untreasury.sell_bond!(@buyer)
        }.to change {@untreasury.bonds.sum(:qty)}.by(-1)
        assert_equal 1, @untreasury.bonds.where(:goal_id => @goal).sum(:qty)    
      end
      
      it "when selling a bond and the buyer has > 0 increments buyer's qty" do
        @treasury.sell_bond!(@buyer)
        assert_equal 1, @buyer.bonds.where(:goal_id => @goal).sum(:qty)    
        expect {
          @untreasury.sell_bond!(@buyer)
        }.to change {@buyer.bonds.sum(:qty)}.by 1
        assert_equal 2, @buyer.bonds.where(:goal_id => @goal).sum(:qty)    
      end
      
      it "selling a bond when you have > 1 and the buyer has none creates the buyer's bond" do
        assert_equal 0, @buyer.bonds.where(:goal_id => @goal).sum(:qty)    
        expect {
          @untreasury.sell_bond!(@buyer)
        }.to change {Bond.count}.by 1
        assert_equal 1, @buyer.bonds.where(:goal_id => @goal).sum(:qty)    
      end
    end
  end
end
