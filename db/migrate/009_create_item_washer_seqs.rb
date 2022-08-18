class CreateItemWasherSeqs < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :item_washer_seqs do |t|
      t.integer :item_id, :null => false
      t.integer :washer_id, :null => false
      t.integer :seq , :null => false
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
    add_index :item_washer_seqs, [:item_id, :washer_id, :seq], :unique => true
  end
  
  def self.down
    drop_table :item_washer_seqs
  end
end
