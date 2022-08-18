class CreateReportsWasherOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :reports_washer_orders, :id => false do |t|
      t.references :washer_order  , :null => false
      t.references :report , :null => false
    end
  end

  def self.down
    drop_table :reports_washer_orders
  end
end
