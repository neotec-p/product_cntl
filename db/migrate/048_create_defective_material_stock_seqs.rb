class CreateDefectiveMaterialStockSeqs < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :defective_material_stock_seqs do |t|
      t.integer :defective_id , :null => false
      t.integer :material_stock_id  , :null => false
      t.decimal :weight , :precision => 10, :scale => 2
      t.integer :seq , :null => false
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
    add_index :defective_material_stock_seqs, [:defective_id, :material_stock_id, :seq], :unique => true, :name => :index_defective_material_stock_seqs_u
  end

  def self.down
    drop_table :defective_material_stock_seqs
  end
end
