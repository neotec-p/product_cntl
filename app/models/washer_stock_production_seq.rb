class WasherStockProductionSeq < ActiveRecord::Base
  belongs_to :washer_stock
  belongs_to :production
end
