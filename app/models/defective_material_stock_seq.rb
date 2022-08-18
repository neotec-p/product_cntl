class DefectiveMaterialStockSeq < ActiveRecord::Base
  belongs_to :defective
  belongs_to :material_stock
end
