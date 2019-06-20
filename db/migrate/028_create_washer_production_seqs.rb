class CreateWasherProductionSeqs < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :washer_production_seqs do |t|
      t.references :washer , :null => false
      t.references :production  , :null => false
      t.integer :seq , :null => false
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
    add_index :washer_production_seqs, [:washer_id, :production_id, :seq], :unique => true, :name => :index_washer_production_seqs_u
  end

  def self.down
    drop_table :washer_production_seqs
  end
end
