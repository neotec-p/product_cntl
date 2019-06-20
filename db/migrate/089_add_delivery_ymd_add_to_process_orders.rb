class AddDeliveryYmdAddToProcessOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :process_orders, :delivery_ymd_add, :string
  end

  def self.down
    remove_column :process_orders, :delivery_ymd_add
  end
end
