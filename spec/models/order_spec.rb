require 'spec_helper'

describe Order do
  describe "has many" do
    describe "line_items and" do
      it "responds to line_items" do
        u = Factory.create(:order)
        u.should respond_to(:line_items)
      end
    end
  end

  describe "belongs to" do
    describe "user and" do
      it "responds to user" do
        u = Factory.create(:order)
        u.should respond_to(:user)
      end
    end
  end
end
