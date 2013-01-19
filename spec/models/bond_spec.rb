require 'spec_helper'

describe Bond do
  
  before :each do
    @c = Factory.create(:account)
    @d = Factory.create(:account)
    @g1 = Factory.create(:goal)
    @g2 = Factory.create(:goal)        
  end

  describe "belongs to" do

    # describe "goal and" do
    #   it "responds to goal" do
    #     u = Factory.create(:bond)
    #     u.should respond_to(:goal)
    #   end
    # end

    describe "creditor and" do
      it "responds to creditor" do
        u = Factory.create(:bond, :creditor => @c)
        u.should respond_to(:creditor)
      end
    end

    describe "debtor and" do
      it "responds to debtor as swap" do
        u = Factory.create(:bond, :debtor => @d)
        u.should respond_to(:debtor)
      end
    end 

  end


  describe "validates" do
    it "that it must have at least a creditor or a debtor" do
      Bond.new(:creditor => @c).should be_valid
      Bond.new(:debtor => @d).should be_valid
      Bond.new.should_not be_valid
    end

    it "that its creditor and debtor must have the same goal" do
      c = Factory.create(:account, :goal => @g1)
      d = Factory.create(:account, :goal => @g2)
      u = Bond.new
      u.creditor = c
      u.debtor   = d
      u.should_not be_valid
    end
  end

  describe "creation" do
    it "defaults to qty 0" do
      @c.bonds.create!(:debtor => @d)
      @c.bonds.last.qty.should be 0
    end
  end 

  describe "pays coupons" do
    it "credits creditor and debits debtor" do
      c = Factory.create(:account)
      d = Factory.create(:account)
      assert c.balance == 0
      assert d.balance == 0
      b = Bond.create!(:creditor => c, :debtor => d, :qty => 1)
      b.pay_coupons
      c.reload
      d.reload
      assert c.balance == 1
      assert d.balance == -1
    end
  end

end
