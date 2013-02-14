class Post < ActiveRecord::Base
  belongs_to :goal

  def to_param
    "#{id}-#{title.parameterize}"
  end
  
end
