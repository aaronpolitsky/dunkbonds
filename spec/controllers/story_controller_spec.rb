require 'spec_helper'

describe StoryController do

  describe "GET 'story1'" do
    it "returns http success" do
      get 'story1'
      response.should be_success
    end
  end

  describe "GET 'story2'" do
    it "returns http success" do
      get 'story2'
      response.should be_success
    end
  end

  describe "GET 'story3'" do
    it "returns http success" do
      get 'story3'
      response.should be_success
    end
  end

  describe "GET 'story4'" do
    it "returns http success" do
      get 'story4'
      response.should be_success
    end
  end

  describe "GET 'story5'" do
    it "returns http success" do
      get 'story5'
      response.should be_success
    end
  end

  describe "GET 'story6'" do
    it "returns http success" do
      get 'story6'
      response.should be_success
    end
  end

  describe "GET 'story7'" do
    it "returns http success" do
      get 'story7'
      response.should be_success
    end
  end

  describe "GET 'storyend'" do
    it "returns http success" do
      get 'storyend'
      response.should be_success
    end
  end

end
