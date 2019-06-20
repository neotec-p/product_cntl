class ChangePriceTypeToProcessOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :process_orders, :price, :decimal, :precision => 10, :scale => 3  , :null => true
  end

  def self.down
    change_column :process_orders, :price, :decimal, :null => true
  end
end
