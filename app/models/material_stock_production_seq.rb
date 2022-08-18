class MaterialStockProductionSeq < ActiveRecord::Base
  belongs_to :material_stock
  belongs_to :production
end
