class Post < ApplicationRecord
  belongs_to :goal

  def to_param
    "#{id}-#{title.parameterize}"
  end
  
end
