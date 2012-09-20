class Goal < ActiveRecord::Base
  PERIODS = ['1 day', '1 week', '1 month']
  validate :period, :inclusion => PERIODS
end
