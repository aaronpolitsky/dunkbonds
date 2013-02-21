require 'spec_helper'

describe AboutController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'credits'" do
    it "returns http success" do
      get 'credits'
      response.should be_success
    end
  end

  describe "GET 'rules'" do
    it "returns http success" do
      get 'rules'
      response.should be_success
    end
  end

  describe "GET 'howitworks'" do
    it "returns http success" do
      get 'howitworks'
      response.should be_success
    end
  end

  describe "GET 'faq'" do
    it "returns http success" do
      get 'faq'
      response.should be_success
    end
  end

  describe "GET 'contact'" do
    it "returns http success" do
      get 'contact'
      response.should be_success
    end
  end

  describe "GET 'why_set_a_goal'" do
    it "returns http success" do
      get 'why_set_a_goal'
      response.should be_success
    end
  end

  describe "GET 'why_trade_dunkbonds'" do
    it "returns http success" do
      get 'why_trade_dunkbonds'
      response.should be_success
    end
  end

end
