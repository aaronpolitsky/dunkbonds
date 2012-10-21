class Goal < ActiveRecord::Base
  has_many :accounts

  PERIODS = ['1 day', '1 week', '1 month']
  validates :period, :inclusion => PERIODS
  validates :title, :description, :presence => true
  validates :starts_at, :presence => true
  validates :ends_at, :presence => true
  validate :dates_and_period_are_appropriate

  after_create :create_treasury

  private

  def create_treasury
    @treasury = self.accounts.create!(:is_treasury => true, 
                                      :balance     => 0.0)
  end

  def dates_and_period_are_appropriate
    #first, defer to dedicated validators
    return if self.starts_at.blank?
    return if self.ends_at.blank?
    return if self.period.blank?
    return unless PERIODS.include? self.period

    if self.ends_at < self.starts_at    
      errors.add(:ends_at, "your goal's end date must be later than its start date.") 
    end

    case self.period
    when '1 day' then
      if self.starts_at.advance(:days => 5) > self.ends_at
        errors.add(:period, "duration must allow for at least 5 periods")
      end
    when '1 week' then
      if self.starts_at.advance(:weeks => 5) > self.ends_at
        errors.add(:period, "duration must allow for at least 5 periods")
      end
    when '1 month' then
      if self.starts_at.advance(:months => 5) > self.ends_at
        errors.add(:period, "duration must allow for at least 5 periods")
      end
      if (self.starts_at != self.starts_at.beginning_of_month) || (self.ends_at != self.ends_at.beginning_of_month)
        errors.add(:starts_at, "a monthly goal must start and end at the beginning of the month")
      end
    end
  end

end


