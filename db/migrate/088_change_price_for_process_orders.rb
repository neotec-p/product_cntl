class ChangePriceForProcessOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :process_orders, :price, :string
  end

  def self.down
    change_column :process_orders, :price, :decimal
  end
end
