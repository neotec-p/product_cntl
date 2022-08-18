class ItemsWasher < ActiveRecord::Base
  belongs_to :item
  belongs_to :washer
  
  validates_presence_of     :item_id
  validates_numericality_of :item_id  
  
  validates_presence_of     :washer_id
  validates_numericality_of :washer_id  
  
  validates_presence_of     :seq
  validates_numericality_of :seq
end
