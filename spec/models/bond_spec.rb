require 'spec_helper'

describe Bond do
  describe "belongs to" do

    describe "goal and" do
      it "responds to goal" do
        u = Factory.create(:bond)
        u.should respond_to(:goal)
      end
    end

    describe "creditor and" do
      it "responds to creditor" do
        u = Factory.create(:bond)
        u.should respond_to(:creditor)
      end
    end

    describe "debtor and" do
      it "responds to debtor as swap" do
        u = Factory.create(:bond)
        u.should respond_to(:debtor)
      end
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
