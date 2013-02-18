Factory.define :goal do |g|
  g.title "blah"
  g.description "blahblah"
  g.starts_at DateTime.civil(2012, 9, 1)
  g.ends_at DateTime.civil(2013, 9, 1)
  g.period "1 month"
  g.blog_url ""
  g.blog_service_provider ''
end

Factory.define :aarondunks, :class => Goal do |g|
  g.title "Aaron DUNKs"
  g.description "Aaron DUNKs a basketball.  Regulation hoop, no trampoline.  Stickum OK."
  g.starts_at DateTime.civil(2012, 5, 1)
  g.ends_at DateTime.civil(2013, 3, 1)
  g.period "1 month"
  g.blog_url "http://dunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'blogspot'
end


Factory.define :boston, :class => Goal do |g|
  g.title "Mateo Qualifies for Boston"
  g.description "Mateo qualifies for this year's Boston marathon."
  g.starts_at DateTime.civil(2013, 3, 1)
  g.ends_at DateTime.civil(2013, 6, 15)
  g.period "none"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'blogspot'
end

Factory.define :par, :class => Goal do |g|
  g.title "David Shoots Par"
  g.description "David shoots par or better at Avalon Lakes."
  g.starts_at DateTime.civil(2013, 3, 1)
  g.ends_at DateTime.civil(2014, 1, 1)
  g.period "none"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'blogspot'
end

Factory.define :goal_w_blog, :class => Goal do |g|
  g.title "blah"
  g.description "blahblah"
  g.starts_at DateTime.civil(2012, 9, 1)
  g.ends_at DateTime.civil(2013, 9, 1)
  g.period "1 month"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'Blogger (blogspot)'
end


#from fixtures
Factory.define :invalid_period, :class => Goal do |g|
  g.title  "title"
  g.description  "desc."
  g.starts_at DateTime.civil(2012, 9, 1)
  g.ends_at DateTime.civil(2013, 9, 1)
  g.period '1 do |g|ohickey'
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'Blogger (blogspot)'
end

Factory.define :backwards_dates, :class => Goal do |g|
  g.title  "title"
  g.description  "desc."
  g.starts_at   DateTime.civil(2012, 9, 21)
  g.ends_at   DateTime.civil(2012, 9, 20)
  g.period   "1 month"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'Blogger (blogspot)'
end

Factory.define :period_longer_than_duration, :class => Goal do |g|
  g.title  "title"
  g.description  "desc."
  g.starts_at   DateTime.civil(2012, 9, 20)
  g.ends_at   DateTime.civil(2012, 9, 21)
  g.period   "1 month"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'Blogger (blogspot)'
end

Factory.define :four_day_daily_period, :class => Goal do |g|
  g.title  "title"
  g.description  "desc."
  g.starts_at   DateTime.civil(2012, 12, 31)
  g.ends_at   DateTime.civil(2013, 1, 3)
  g.period   "1 day"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'Blogger (blogspot)'
end

Factory.define :four_week_weekly_period, :class => Goal do |g|
  g.title  "title"
  g.description  "desc."
  g.starts_at   DateTime.civil(2012, 12, 31)
  g.ends_at   DateTime.civil(2013, 1, 28)
  g.period   "1 week"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'Blogger (blogspot)'
end

Factory.define :four_month_monthly_period, :class => Goal do |g|
  g.title  "title"
  g.description  "desc."
  g.starts_at   DateTime.civil(2012, 12, 1)
  g.ends_at   DateTime.civil(2013, 3, 1)
  g.period   "1 month"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'Blogger (blogspot)'
end

Factory.define :not_monthly_aligned, :class => Goal do |g|
  g.title  "title"
  g.description  "desc."
  g.starts_at   DateTime.civil(2012, 12, 4)
  g.ends_at   DateTime.civil(2013, 3, 4)
  g.period   "1 month"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'Blogger (blogspot)'
end

Factory.define :certain_date_goal, :class => Goal do |g|
  g.title  "title"
  g.description  "desc."
  g.starts_at   DateTime.civil(2012, 12, 4)
  g.ends_at   DateTime.civil(2013, 5, 18)
  g.period   "none"
  g.blog_url "http://rsstestdunkbonds.blogspot.com/feeds/posts/default"
  g.blog_service_provider 'Blogger (blogspot)'
end








