class CreateOrders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :orders do |t|
      t.integer :item_id  , :null => false
      t.date  :formation_ymd  , :null => false
      t.string  :order_no , :null => false  , :limit => 10
      t.integer :order_amount , :null => false
      t.date  :delivery_ymd , :null => false
      t.integer :necessary_amount
      t.date  :order_ymd  , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
