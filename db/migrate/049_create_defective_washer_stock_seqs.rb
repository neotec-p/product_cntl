class CreateDefectiveWasherStockSeqs < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :defective_washer_stock_seqs do |t|
      t.integer :defective_id , :null => false
      t.integer :washer_stock_id  , :null => false
      t.integer :quantity
      t.integer :seq , :null => false
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
    add_index :defective_washer_stock_seqs, [:defective_id, :washer_stock_id, :seq], :unique => true, :name => :index_defective_washer_stock_seqs_u
  end

  def self.down
    drop_table :defective_washer_stock_seqs
  end
end
