class WasherUnitPriceHistory < ActiveRecord::Base
  belongs_to :washer
  
  validates_presence_of     :unit_price
  validates_numericality_of :unit_price, :allow_blank => true
  
end
