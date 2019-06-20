class ItemWasherSeq < ActiveRecord::Base
  belongs_to :item
  belongs_to :washer
end
