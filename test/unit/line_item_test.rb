require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "line_item status must be 'new'" do
    li = LineItem.create!(:one)

    assert li.status == "new"
  end


end
