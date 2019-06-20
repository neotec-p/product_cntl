class MaterialUnitPriceHistory < ActiveRecord::Base
  belongs_to :material
  
  validates_presence_of     :unit_price
  validates_numericality_of :unit_price, :allow_blank => true
  
end
