class ItemMaterialSeq < ActiveRecord::Base
  belongs_to :item
  belongs_to :material
end
