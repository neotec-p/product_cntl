class CreateWashers < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :washers do |t|
      t.string  :steel_class, :null => false
      t.string  :diameter, :null => false
      t.string  :surface      
      t.integer :unit  , :null => false
      t.decimal :unit_price  , :precision => 10, :scale => 2, :null => false      
      t.date  :start_ymd  , :null => false
      t.date  :end_ymd  , :null => false
      t.date  :created_ymd  , :null => false
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :washers
  end
end
