require 'spec_helper'

describe Payment do
	before :each do 
		@payer = Factory.create(:account)
		@recipient = Factory.create(:account)
	end
	
	describe "belongs_to" do
		it "a payer and a recipient" do
			p =	Payment.new(:payer => @payer,
			   			        :recipient => @recipient,
			   			        :amount => 2.50)
			p.should respond_to	:payer
			p.payer.should eq @payer
			p.should respond_to	:recipient			
			p.recipient.should eq @recipient			
		end
	end

	describe "must" do
		it "have both a payer and a recipient" do
			Payment.new(:payer => @payer, :amount => 2.50).should_not be_valid
			Payment.new(:recipient => @recipient, :amount => 2.50).should_not be_valid
		end

		it "have an amount > 0 and <= 100" do
			@payer.payments.new(:recipient => @recipient).should_not be_valid
			@payer.payments.new(:recipient => @recipient,
			                    :amount => -1).should_not be_valid						
			@payer.payments.new(:recipient => @recipient,
			                    :amount => 101).should_not be_valid						
			@payer.payments.new(:recipient => @recipient,
			                    :amount => 0).should_not be_valid									
			@payer.payments.new(:recipient => @recipient,
			                    :amount => 1).should be_valid		
			
			@recipient.receipts.new(:payer => @payer).should_not be_valid
			@recipient.receipts.new(:payer => @payer,
			                        :amount => -1).should_not be_valid						
			@recipient.receipts.new(:payer => @payer,
			                        :amount => 101).should_not be_valid						
			@recipient.receipts.new(:payer => @payer,
			                        :amount => 0).should_not be_valid									
			@recipient.receipts.new(:payer => @payer,
			                        :amount => 1).should be_valid					                    							
		end
	end

	describe "creation" do
		it "debits payer and credits recipient" do
			p = @payer.payments.new(:recipient => @recipient,
					                    :amount => 12.50)
			p.save! # }.to change(@payer.reload, :balance).by(-12.50)
			@payer.reload.balance.should eq -12.50
			@recipient.reload.balance.should eq 12.50			
			# to change(@recipient.reload, :balance).by 12.50
		end
	end
end
