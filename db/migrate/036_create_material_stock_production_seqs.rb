class CreateMaterialStockProductionSeqs < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :material_stock_production_seqs do |t|
      t.integer :material_stock_id , :null => false
      t.integer :production_id  , :null => false
      t.integer :seq , :null => false
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
    add_index :material_stock_production_seqs, [:material_stock_id, :production_id, :seq], :unique => true, :name => :index_material_stock_production_seqs_u
  end

  def self.down
    drop_table :material_stock_production_seqs
  end
end
