class User < ActiveRecord::Base
  has_many :accounts
  has_many :followed_goals, :through => :accounts, :source => :goal #class_name => "Goal"
  has_many :orders
  has_many :line_items, :through => :orders

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  def follow_goal(goal) #return false if already following goal
    self.followed_goals << goal 
    true
  rescue ActiveRecord::RecordNotUnique
    false
  end

  def following?(goal)
    self.followed_goals.include?(goal)
  end

end



