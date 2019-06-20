class CreateCheckSheets < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :check_sheets do |t|
      t.string  :type , :null => false    
      t.integer :item_id  , :null => false    
      t.string  :column1      
      t.string  :standard1_top
      t.string  :standard1_bottom
      t.string  :column2      
      t.string  :standard2_top      
      t.string  :standard2_bottom     
      t.string  :column3      
      t.string  :standard3_top      
      t.string  :standard3_bottom     
      t.string  :column4      
      t.string  :standard4_top      
      t.string  :standard4_bottom     
      t.string  :column5      
      t.string  :standard5_top      
      t.string  :standard5_bottom     
      t.string  :column6      
      t.string  :standard6_top      
      t.string  :standard6_bottom     
      t.string  :column7      
      t.string  :standard7_top      
      t.string  :standard7_bottom     
      t.string  :column8      
      t.string  :standard8_top      
      t.string  :standard8_bottom     
      t.string  :column9      
      t.string  :standard9_top      
      t.string  :standard9_bottom     
      t.string  :column10     
      t.string  :standard10_top     
      t.string  :standard10_bottom      
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :check_sheets
  end
end
