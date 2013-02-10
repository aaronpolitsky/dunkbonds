require 'spec_helper'

describe Payment do
	before :each do 
		@payee = Factory.create(:account)
		@recipient = Factory.create(:account)
	end
	
	describe "belongs_to" do
		it "a payee and a recipient" do
			p =	Payment.new(:payee => @payee,
			   			        :recipient => @recipient,
			   			        :amount => 2.50)
			p.should respond_to	:payee
			p.payee.should eq @payee
			p.should respond_to	:recipient			
			p.recipient.should eq @recipient			
		end
	end

	describe "must" do
		it "have both a payee and a recipient" do
			Payment.new(:payee => @payee, :amount => 2.50).should_not be_valid
			Payment.new(:recipient => @recipient, :amount => 2.50).should_not be_valid
		end

		it "have an amount > 0 and <= 100" do
			@payee.payments.new(:recipient => @recipient).should_not be_valid
			@payee.payments.new(:recipient => @recipient,
			                    :amount => -1).should_not be_valid						
			@payee.payments.new(:recipient => @recipient,
			                    :amount => 101).should_not be_valid						
			@payee.payments.new(:recipient => @recipient,
			                    :amount => 0).should_not be_valid									
			@payee.payments.new(:recipient => @recipient,
			                    :amount => 1).should be_valid		
			
			@recipient.receipts.new(:payee => @payee).should_not be_valid
			@recipient.receipts.new(:payee => @payee,
			                        :amount => -1).should_not be_valid						
			@recipient.receipts.new(:payee => @payee,
			                        :amount => 101).should_not be_valid						
			@recipient.receipts.new(:payee => @payee,
			                        :amount => 0).should_not be_valid									
			@recipient.receipts.new(:payee => @payee,
			                        :amount => 1).should be_valid					                    							
		end
	end

	describe "creation" do
		it "debits payee and credits recipient" do
			p = @payee.payments.new(:recipient => @recipient,
					                    :amount => 12.50)
			p.save! # }.to change(@payee.reload, :balance).by(-12.50)
			@payee.reload.balance.should eq -12.50
			@recipient.reload.balance.should eq 12.50			
			# to change(@recipient.reload, :balance).by 12.50
		end
	end
end
