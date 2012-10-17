require 'test_helper'

class BondTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "a new bond row has qty 1 by default" do
    b = Bond.new
#    assert_equal 1, b.qty
  end

  test "a bond's accounts must be of the same goal" do
    g1 = goals(:one)
    creditor = g1.accounts.new                              
    debtor = g1.accounts.new
    g2 = goals(:two)
    b = Bond.new(:goal => g2, :debtor_id => debtor, :creditor_id => creditor)
 #   assert b.invalid?
  end

end
