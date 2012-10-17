require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  setup do
    @goal = goals(:one)
    @treasury = accounts(:treasury)
    @buyer  = accounts(:acct)
    @goal.accounts << @treasury
    @goal.accounts << @buyer
  end

  test "initial balance should be zero" do
    a = Account.create!
#    assert_equal 0.0, a.balance
  end
  
  test "the first bond between accounts should create a new bond row" do
    @treasury.sell_bond!(@buyer)
    assert_equal 1, @buyer.bonds.count
    assert_equal 1, @treasury.swaps.count
    assert_equal 1, @buyer.bonds.first.qty
    assert_equal 1, @treasury.swaps.first.qty
  end
  
  test "the second bond between accounts should increment bond quantity rather than create a new bond row" do
    @treasury.sell_bond!(@buyer)
    @treasury.sell_bond!(@buyer)
    assert_equal 1, @buyer.bonds.count
    assert_equal 1, @treasury.swaps.count
    assert_equal 2, @buyer.bonds.first.qty
    assert_equal 2, @treasury.swaps.first.qty
  end
  
  test "only the treasury can create a bond from thin air" do
    untreasury = @goal.accounts.create!(:is_treasury => false, :balance => 0.0)
    assert_difference('Bond.count', 0) do
      untreasury.sell_bond!(@buyer)
    end
    assert_equal 0, untreasury.swaps.count
  end

  test "a regular account cannot sell a bond it does not have" do
    untreasury = @goal.accounts.create!(:is_treasury => false, :balance => 0.0)
    assert untreasury.bonds.empty?
    assert_difference('@buyer.bonds.sum(:qty)', 0) do
      untreasury.sell_bond!(@buyer)
    end
  end  

  test "a regular account can sell a bond if it has one to sell" do
    untreasury = @goal.accounts.create!(:is_treasury => false, :balance => 0.0)
    @treasury.sell_bond!(untreasury)
    assert_equal 1, untreasury.bonds.where(:goal_id => @goal).sum(:qty)
    assert_difference('@buyer.bonds.sum(:qty)', 1) do
      untreasury.sell_bond!(@buyer)
    end
    assert_equal 0, untreasury.bonds.where(:goal_id => @goal).sum(:qty)
  end

  test "selling a bond decrements seller' qty if seller's qty > 1" do
    untreasury = @goal.accounts.create!(:is_treasury => false, :balance => 0.0)
    @treasury.sell_bond!(untreasury)
    @treasury.sell_bond!(untreasury)
    assert_equal 2, untreasury.bonds.where(:goal_id => @goal).sum(:qty)    
    assert_difference('untreasury.bonds.sum(:qty)', -1) do
      untreasury.sell_bond!(@buyer)
    end
    assert_equal 1, untreasury.bonds.where(:goal_id => @goal).sum(:qty)    
  end

  test "selling a bond when you have > 1 and the buyer has > 0 increments buyer's qty" do
    untreasury = @goal.accounts.create!(:is_treasury => false, :balance => 0.0)
    @treasury.sell_bond!(untreasury)
    @treasury.sell_bond!(untreasury)
    assert_equal 2, untreasury.bonds.where(:goal_id => @goal).sum(:qty)    
    @treasury.sell_bond!(@buyer)
    assert_equal 1, @buyer.bonds.where(:goal_id => @goal).sum(:qty)    
    assert_difference('@buyer.bonds.sum(:qty)', 1) do
      untreasury.sell_bond!(@buyer)
    end
    assert_equal 2, @buyer.bonds.where(:goal_id => @goal).sum(:qty)    
  end

  test "selling a bond when you have > 1 and the buyer has none creates the buyer's bond" do
    untreasury = @goal.accounts.create!(:is_treasury => false, :balance => 0.0)
    @treasury.sell_bond!(untreasury)
    @treasury.sell_bond!(untreasury)
    assert_equal 2, untreasury.bonds.where(:goal_id => @goal).sum(:qty)    
    assert_equal 0, @buyer.bonds.where(:goal_id => @goal).sum(:qty)    
    assert_difference('Bond.count', 1) do
      untreasury.sell_bond!(@buyer)
    end
    assert_equal 1, @buyer.bonds.where(:goal_id => @goal).sum(:qty)    
  end

end
