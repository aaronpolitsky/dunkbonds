require 'spec_helper'

describe Cart do

  describe "has many" do
    it "line items and responds to line_items" do
      li = Factory.create(:line_item)
      cart = Cart.create!
      cart.line_items << li
      cart.should respond_to :line_items
      assert cart.line_items.include?(li)
    end
  end

end
