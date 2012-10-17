class Goal < ActiveRecord::Base
  has_many :accounts

  PERIODS = ['1 day', '1 week', '1 month']
  validates :period, :inclusion => PERIODS
  validates :title, :description, :presence => true
  validates :starts_at, :presence => true
  validates :ends_at, :presence => true
  validates :ends_at, :numericality => {:greater_than => :starts_at}

  after_create :create_treasury

  private

  def create_treasury
    @treasury = self.accounts.create!(:is_treasury => true, 
                                      :balance     => 0.0)
  end
end
