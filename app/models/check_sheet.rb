class CheckSheet < ActiveRecord::Base
  belongs_to :item

  validates_presence_of     :item_id
  validates_numericality_of :item_id
end
