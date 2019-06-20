class CreateProcessRatios < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :process_ratios do |t|
      t.integer :hd , :null => false
      t.integer :barrel , :null => false 
      t.integer :ro1 , :null => false  
      t.integer :ro2 , :null => false  
      t.integer :heat , :null => false 
      t.integer :surface , :null => false
      t.decimal :conf_inspection , :null => false , :precision => 5, :scale => 3  
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :process_ratios
  end
end
