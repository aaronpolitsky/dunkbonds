class Order < ActiveRecord::Base
  belongs_to :user
  has_many :line_items, :dependent => :destroy

  def get_cart_items(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      self.line_items << item
    end
    self.save!
  end

  def execute_line_items
    self.line_items.each do |item|
      item.execute!
    end
  end
end
