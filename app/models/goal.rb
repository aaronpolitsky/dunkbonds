class Goal < ActiveRecord::Base
  has_many :accounts

  PERIODS = ['1 day', '1 week', '1 month']
  validate :period, :inclusion => PERIODS

  after_create :create_treasury

  private

  def create_treasury
    @treasury = self.accounts.create!(:is_treasury => true, 
                                      :balance     => 0.0)
  end
end
