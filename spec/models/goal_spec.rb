require 'spec_helper'

describe Goal do

  it "must have valid attributes" do
    g = Goal.new
    assert g.invalid?
    assert g.errors[:title].any?
    assert g.errors[:description].any?
    assert g.errors[:starts_at].any?
    assert g.errors[:ends_at].any?
    assert g.errors[:period].any?
  end 
  
  describe "goal dates: " do
    it "ends_at must be later than starts_at" do
      g = Factory.build(:backwards_dates)
      assert g.invalid?
      assert g.errors[:ends_at].any?
    end
  end

  describe "with uncertain completion dates: " do
    it "period must be 1 day, 1 week, or 1 month" do
      g = Factory.build(:invalid_period)
      assert g.invalid?
      assert g.errors[:period].any?
    end
    
    it "period must not be longer than duration" do
      g = Factory.build(:period_longer_than_duration)
      assert g.invalid?
    end
    
    it "a monthly period goal's dates must be aligned to first of month" do
      g = Factory.build(:not_monthly_aligned)
      assert g.invalid?
      assert g.errors.any?
    end
    
    it "duration must allow for at least 5 periods" do
      g = Factory.build(:four_week_weekly_period)
      assert g.invalid?
      assert g.errors.any?
      g = Factory.build(:four_day_daily_period)
      assert g.invalid?
      assert g.errors.any?
      g = Factory.build(:four_month_monthly_period)
      assert g.invalid?
      assert g.errors.any?
    end
  end

  describe "goals with certain do or die dates:" do
    it "do not have a period" do
      g = Factory.build(:certain_date_goal)
      assert g.valid?
      g.period = "1 month"
      assert g.invalid?
    end

    it "starts_at and ends_at can be whenever, so long as they're in order" do
      g = Factory.build(:certain_date_goal)
      assert g.valid?
      g.starts_at = g.ends_at + 1.day
      assert g.invalid?
    end
  end

  describe "a change to the blog_url" do
    before :each do
      @goal = Factory.create(:goal_w_blog)
      @goal.update_from_feed
      @goal.reload
      @posts = @goal.posts.all
      @goal.blog_url = 'http://dunkbonds.blogspot.com/feeds/posts/default'
      @goal.save!
      @goal.reload
    end
    
    it "deletes the old posts" do
      assert !@goal.posts.include?(@posts.first)          
    end
    
    pending "fetches the new posts from new blog feed" do
      assert @goal.posts != @posts
      feed = feedjira::Feed.fetch_and_parse(@goal.blog_url)
      gs = @goal.posts.all
      fs = feed.entries
      gs.zip(fs).each do |pair|
        assert pair[0].title        == pair[1].title
        assert pair[0].url          == pair[1].url
        assert pair[0].content      == pair[1].content
        assert pair[0].published_at == pair[1].published
        assert pair[0].guid         == pair[1].id
      end
    end
  end

  describe "has many" do
    describe "posts and" do
      it "should respond to posts" do
        g = Factory.build(:goal_w_blog)
        g.should respond_to(:posts)
      end
    end

    describe "followers and" do
      it "should respond to followers" do
        g = Factory.build(:goal)
        g.should respond_to(:followers)
      end
    end

    describe "line_items and" do
      it "should respond to line_items" do
        g = Factory.build(:goal)
        g.should respond_to(:line_items)
      end
    end
  end
  
  describe "has a feed and" do
    pending "the goal validates the feed" do
      g = Factory.build(:goal_w_blog, :blog_url => "www.google.com")
      g.should_not be_valid
      g.errors[:blog_url].should include("Double check that blog url.")
    end
    
    describe "retrieval" do
      before :each do
        @g = Factory.create(:goal_w_blog)
      end
      
      describe "of new posts" do 
        it "creates new posts" do
          expect {
            @g.update_from_feed
          }.to change{Post.count}
        end
      end
      
      describe "of existing posts" do
        pending "does not create a new post" do
          @g.update_from_feed
          expect {
            @g.update_from_feed
          }.to_not change{Post.count}
        end
        
        pending "updates posts" do
          @g.update_from_feed
          p = @g.posts.first
          p.title = "XXX"
          p.save!
          expect {
            @g.update_from_feed
          }.to change{@g.posts.first.reload.title}
        end
      end
    end
  end
  
end

