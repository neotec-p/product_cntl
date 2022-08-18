class RemoveItemIdFromOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    remove_column :orders, :item_id
  end

  def self.down
    add_column :orders, :item_id, :integer
  end
end
