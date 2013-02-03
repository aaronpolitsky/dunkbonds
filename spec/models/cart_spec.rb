require 'spec_helper'

describe Cart do

	before :each do
    @user = Factory.create(:user)
    @goal1 = Factory.create(:goal)
    @goal2 = Factory.create(:goal)
    @user.follow_goal(@goal1)
    @user.follow_goal(@goal2)
    @buyer1  = @user.accounts.first
    @buyer2  = @user.accounts.last    
    @treasury1 = @goal1.treasury
    @treasury2 = @goal2.treasury
		@cart = Cart.create!
	end

  describe "has many" do
    it "line items and responds to line_items" do
      li1 = @buyer1.line_items.create!(:type_of => "bond bid",
                                       :qty => 10,
                                       :max_bid_min_ask => 10)
      li2 = @buyer2.line_items.create!(:type_of => "bond bid",
                                       :qty => 10,
                                       :max_bid_min_ask => 10)      
      @cart.line_items << li1
      @cart.line_items << li2      
      @cart.should respond_to :line_items
      @cart.line_items.should include li1
      @cart.line_items.should include li2
    end
  end

  describe "validates" do
  	it "that each account has enough bonds to cover its asks" do
      pending "moved this to line_item validation"
  		@buyer1.bonds.create!(:debtor => @treasury, :qty => 1)
  		@buyer2.bonds.create!(:debtor => @treasury, :qty => 1)
      li1 = @buyer1.line_items.create!(:type_of => "bond ask",
                                       :qty => 1,
                                       :max_bid_min_ask => 10)
      li2 = @buyer1.line_items.create!(:type_of => "bond ask",
                                       :qty => 1,
                                       :max_bid_min_ask => 10)
      li3 = @buyer2.line_items.create!(:type_of => "bond ask",
                                       :qty => 1,
                                       :max_bid_min_ask => 10)
			sw1 = @buyer2.line_items.create!(:type_of => "swap bid",
			                                 :qty => 3,
			                                 :max_bid_min_ask => 10)
			@cart.line_items << sw1
			
      @cart.line_items << li1
      @cart.should be_valid

      @cart.line_items << li3      
      @cart.should be_valid

      @buyer2.bonds.first.decrement!
      @cart.should_not be_valid

      @cart.line_items << li2
      @cart.should_not be_valid
  	end
  end

end
