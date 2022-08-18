class CreateWasherUnitPriceHistories < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :washer_unit_price_histories do |t|
      t.integer :washer_id, :null => false
      t.decimal :unit_price  , :precision => 10, :scale => 2
      t.date  :start_ymd  , :null => false
      t.date  :end_ymd  , :null => false
      t.date  :created_ymd  , :null => false
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
    
    add_index :washer_unit_price_histories, [:washer_id, :start_ymd, :end_ymd], :unique => true, :name => :index_washer_unit_price_histories_u
  end
  
  def self.down
    drop_table :washer_unit_price_histories
  end
end
