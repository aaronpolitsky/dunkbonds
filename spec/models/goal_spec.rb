require 'spec_helper'

describe Goal do

  pending "add some examples to (or delete) #{__FILE__}"

  it "must have valid attributes" do
    g = Goal.new
    assert g.invalid?
    assert g.errors[:title].any?
    assert g.errors[:description].any?
    assert g.errors[:starts_at].any?
    assert g.errors[:ends_at].any?
    assert g.errors[:period].any?
  end 
  
  describe "goal dates and period: " do
    it "ends_at must be later than starts_at" do
      g = Factory.build(:backwards_dates)
      assert g.invalid?
      assert g.errors[:ends_at].any?
    end
    
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

  describe "posts" do
    it "has many" do
      g = Factory.build(:goal)
      g.should respond_to(:posts)
    end

    pending "the goal validates the feed" do

    end

    describe "feed retrieval" do
      before :each do
        @g = Factory.create(:goal)
      end

      describe "of new posts" do 
        it "creates new posts" do
          expect {
            @g.update_from_feed
          }.to change{Post.count}
        end
      end

      describe "of existing posts" do
        it "does not create a new post" do
            @g.update_from_feed
          expect {
            @g.update_from_feed
          }.to_not change{Post.count}
        end

        it "updates post" do
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

