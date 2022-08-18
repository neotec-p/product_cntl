class Trader < ActiveRecord::Base
  has_many :process_orders
  has_many :material_orders
  
  validates_presence_of     :name

  # public instance method =====================================================
  def disp_text
    name + ":" + id.to_s
  end

end
