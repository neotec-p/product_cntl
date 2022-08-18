class CreateProcessOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :process_orders do |t|
      t.integer :production_detail_id , :null => false
      t.string :type , :null => false
      t.integer :trader_id  , :null => false
      t.string  :material
      t.string  :thickness
      t.string  :process
      t.date  :delivery_ymd  , :null => false
      t.string  :summary1
      t.string  :summary2
      t.decimal :price
      t.date  :order_ymd  , :null => false
      t.date  :arrival_ymd
      t.integer :print_flag , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :process_orders
  end
end
