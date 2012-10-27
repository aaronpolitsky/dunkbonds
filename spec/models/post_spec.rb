require 'spec_helper'

describe Post do

  it "belongs to goal" do
    g = Factory.build(:goal)    
    p = Factory.build(:post)
    g.posts << p
    p.should respond_to(:goal)
  end


end
