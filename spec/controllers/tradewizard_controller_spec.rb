require 'spec_helper'

describe TradewizardController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'review'" do
    it "returns http success" do
      get 'review'
      response.should be_success
    end
  end

end
