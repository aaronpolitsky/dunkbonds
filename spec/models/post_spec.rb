require 'spec_helper'

describe Post do

  describe "belongs to" do
    describe "goal and" do
      it "responds to goal" do
        p = Factory.build(:post)
        p.should respond_to(:goal)
      end
    end
  end



end
