class ChangeUnitPriceTypeToMaterials < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :materials, :unit_price, :decimal, :precision => 10, :scale => 3  , :null => false
  end

  def self.down
    change_column :materials, :unit_price, :decimal, :precision => 10, :scale => 2  , :null => false
  end
end
