class ChangeAdjustWeightTypeToMaterialStocks < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :material_stocks, :adjust_weight, :decimal, :precision => 10, :scale => 1
  end

  def self.down
    change_column :material_stocks, :adjust_weight, :decimal, :precision => 10, :scale => 2
  end
end
