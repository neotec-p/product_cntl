class CreateProcessPrices < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :process_prices do |t|
      t.string  :type , :null => false
      t.integer :item_id  , :null => false
      t.integer :trader_id , :null => false
      t.integer :material_id , :null => false
      t.string  :customer_code  , :null => false  , :limit => 3
      t.string  :code , :null => false  , :limit => 4
      t.string  :process , :null => false
      t.string  :condition
      t.decimal :price , :null => false  , :precision => 10, :scale => 2      
      t.string  :unit
      t.string  :set
      t.decimal :addition_price  , :precision => 10, :scale => 2     
      t.string  :addition_unit      
      t.decimal :condition_weight  , :precision => 10, :scale => 2     
      t.string  :condition_following      
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :process_prices
  end
end
