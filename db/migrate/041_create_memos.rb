class CreateMemos < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :memos do |t|
      t.integer :production_id  , :null => false    
      t.integer :seq  , :null => false    
      t.string  :contents , :null => false    
      t.integer :user_id  , :null => false    
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
    
    add_index :memos, [:production_id, :seq], :unique => true
  end

  def self.down
    drop_table :memos
  end
end
