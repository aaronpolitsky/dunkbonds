class Order < ActiveRecord::Base
  belongs_to :account
  has_many :line_items, :dependent => :destroy

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      self.line_items << item
    end
  end

  def execute_line_items
    line_items.each do |item|
      item.execute!
    end
  end
end
