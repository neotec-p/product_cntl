class DefectiveWasherStockSeq < ActiveRecord::Base
  belongs_to :defective
  belongs_to :washer_stock
end
