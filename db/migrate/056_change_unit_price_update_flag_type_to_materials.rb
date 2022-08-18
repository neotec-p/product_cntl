class ChangeUnitPriceUpdateFlagTypeToMaterials < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :materials, :unit_price_update_flag, :integer, :null => true
  end

  def self.down
    change_column :materials, :unit_price_update_flag, :integer, :null => false
  end
end
