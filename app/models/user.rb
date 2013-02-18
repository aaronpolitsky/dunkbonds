class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name

  has_many :accounts, :dependent => :destroy
  has_many :line_items, :through => :accounts
  has_many :followed_goals, :through => :accounts, :source => :goal #class_name => "Goal"
  has_many :orders
  has_one :cart, :dependent => :destroy
  has_many :goals, :foreign_key => :goalsetter_id

  after_create {self.create_cart!}

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  def full_name
    self.first_name + ' ' + self.last_name
  end

  def follow_goal(goal) #return false if already following goal
    self.followed_goals << goal 
    true
  rescue ActiveRecord::RecordNotUnique
    false
  end

  def following?(goal)
    self.followed_goals.include?(goal)
  end

  def supporting?(goal) 
    self.following?(goal) && self.accounts.find_by_goal_id(goal.id).supporting?
  rescue ActiveRecord::RecordNotFound
    false
  end

end



