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

  test "goal dates and period must be chosen to allow for several periods" do
    g = goals(:period_longer_than_duration)
    g.invalid?
  end

  test "period must be 1 day, 1 week, or 1 month" do
    g = goals(:one)
    assert g.invalid?
    assert g.errors[:period].any?
  end
end
