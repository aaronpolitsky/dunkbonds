class Goal < ActiveRecord::Base
  has_many :accounts
  has_many :posts
  has_many :followers, :through => :accounts, :class_name => "User"
  has_many :line_items, :through => :accounts
  
  PERIODS = ['none', '1 day', '1 week', '1 month']
  BLOG_SERVICES = ['other', 'Blogger (blogspot)']

  validates :period, :inclusion => PERIODS
  validates :title, :description, :presence => true
  validates :starts_at, :presence => true
  validates :ends_at, :presence => true

  validate :dates_and_period_are_appropriate
  validate :blog_url_is_valid

  after_create :create_treasury
  
  before_update :purge_old_posts_and_update_feed_on_blog_changes

  def update_from_feed()
    unless self.blog_url.nil? || self.blog_url.empty?
      feed = Feedzirra::Feed.fetch_and_parse(self.blog_url)
      add_or_update_entries(feed.entries) unless (feed == 0 || feed.entries.empty?)
    end
  end

  def add_or_update_entries(entries)
    (entries.sort_by { |e| e.published }).each do |entry|
      unless self.posts.exists? :guid => entry.id
        self.posts.create!(
                           :title        => entry.title,
                           :content      => entry.content,
                           :url          => entry.url,
                           :published_at => entry.published,
                           :guid         => entry.id
        )
      else
        post = self.posts.find_by_guid(entry.id)
        post.update_attributes!(
                               :title        => entry.title,
                               :content      => entry.content,
                               :url          => entry.url,
                               :published_at => entry.published,
                               :guid         => entry.id
                               )
      end
    end
  end

  private
  
  def purge_old_posts_and_update_feed_on_blog_changes
    unless self.changes[:blog_url].nil?
      self.posts.all.each do |p|
        p.destroy
      end        
      self.update_from_feed
    end
  end
  

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
  
  def blog_url_is_valid
    unless self.blog_url.nil? || self.blog_url.empty? #blog CAN be empty
      Feedzirra::Feed.fetch_and_parse(self.blog_url, :on_failure => lambda { self.errors.add(:blog_url, "Double check that blog url.") } )
    end
    errors.blank?
  end

end


