class ChangeColumnsForWasherOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :washer_orders, :purchase_price, :decimal, :precision => 10, :scale => 3, :null => true
  end

  def self.down
    change_column :washer_orders, :purchase_price, :decimal, :precision => 10, :scale => 0, :null => true
  end
end
