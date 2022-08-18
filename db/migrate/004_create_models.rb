class CreateModels < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :models do |t|
      t.string  :code , :null => false  , :limit => 3 
      t.string  :name , :null => false    
      t.string  :note
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
    
    add_index :models, [:code, :name], :unique => true
  end
  
  def self.down
    drop_table :models
  end
end
