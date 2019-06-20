class CreateMaterials < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :materials do |t|
      t.string  :standard , :null => false , :limit => 50
      t.decimal :diameter , :null => false , :precision => 10, :scale => 2
      t.string  :surface  , :limit => 50
      t.string  :process  , :limit => 50
      t.decimal :dimensions  , :precision => 10, :scale => 2
      t.decimal :unit_price   , :precision => 10, :scale => 2  , :null => false
      t.integer :unit_price_update_flag  , :null => false
      t.date  :start_ymd  , :null => false
      t.date  :end_ymd  , :null => false
      t.date  :created_ymd  , :null => false
      t.integer :lock_version  , :null => false    , :default => 0
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :materials
  end
end
