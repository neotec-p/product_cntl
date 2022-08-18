class ChangeColumnsForMaterialOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :material_orders, :order_weight, :integer, :null => false
    change_column :material_orders, :purchase_price, :decimal, :precision => 10, :scale => 3, :null => true
  end

  def self.down
    change_column :material_orders, :order_weight, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :material_orders, :purchase_price, :decimal, :precision => 10, :scale => 0, :null => true
  end
end
