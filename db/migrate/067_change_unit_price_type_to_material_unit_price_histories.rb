class ChangeUnitPriceTypeToMaterialUnitPriceHistories < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :material_unit_price_histories, :unit_price, :decimal, :precision => 10, :scale => 3  , :null => true
  end

  def self.down
    change_column :material_unit_price_histories, :unit_price, :decimal, :precision => 10, :scale => 2  , :null => true
  end
end
