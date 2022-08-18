class CreateWasherStocks < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :washer_stocks do |t|
      t.integer :washer_id  , :null => false
      t.integer :washer_order_id  , :null => false
      t.string  :inspection_no
      t.integer :accept_quantity  , :null => false
      t.date  :accept_ymd , :null => false
      t.integer :adjust_quantity
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :washer_stocks
  end
end
