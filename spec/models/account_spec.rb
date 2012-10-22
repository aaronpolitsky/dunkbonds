require 'spec_helper'

describe Account do
  fixtures :goals, :accounts
  before do
    @goal = goals(:one)
    @treasury = accounts(:treasury)
    @buyer  = accounts(:acct)
    @goal.accounts << @treasury
    @goal.accounts << @buyer
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
