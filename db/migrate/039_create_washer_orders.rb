class CreateWasherOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :washer_orders do |t|
      t.integer :washer_id  , :null => false    
      t.integer :trader_id  , :null => false    
      t.date  :order_ymd      
      t.integer :order_quantity  , :null => false
      t.date  :delivery_ymd  , :null => false
      t.decimal :purchase_price     
      t.date  :reply_delivery_ymd     
      t.date  :full_delivery_ymd      
      t.integer :print_flag  , :null => false
      t.integer :delivery_flag  , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :washer_orders
  end
end
