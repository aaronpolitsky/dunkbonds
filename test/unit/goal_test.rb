require 'test_helper'

class GoalTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "must have valid attributes" do
    g = Goal.new
    assert g.invalid?
    assert g.errors[:title].any?
    assert g.errors[:description].any?
    assert g.errors[:starts_at].any?
    assert g.errors[:ends_at].any?
    assert g.errors[:period].any?
  end

  test "ends_at must be later than starts_at" do
    g = goals(:backwards_dates)
    assert g.invalid?
    assert g.errors[:ends_at].any?
  end

  test "period must be 1 day, 1 week, or 1 month" do
    g = goals(:invalid_period)
    assert g.invalid?
    assert g.errors[:period].any?
  end

  test "period must not be longer than duration" do
    g = goals(:period_longer_than_duration)
    assert g.invalid?
  end

  test "a monthly period goal's dates must be aligned to first of month" do
    g = goals(:not_monthly_aligned)
    assert g.invalid?
    assert g.errors.any?
  end

  test "duration must allow for at least 5 periods" do
    g = goals(:four_week_weekly_period)
    assert g.invalid?
    assert g.errors.any?
    g = goals(:four_day_daily_period)
    assert g.invalid?
    assert g.errors.any?
    g = goals(:four_month_monthly_period)
    assert g.invalid?
    assert g.errors.any?
  end

end
