class ChangeColumnsForDefectiveMaterialStockSeqs < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :defective_material_stock_seqs, :weight, :decimal, :precision => 10, :scale => 1, :null => true
  end

  def self.down
    change_column :defective_material_stock_seqs, :weight, :decimal, :precision => 10, :scale => 2, :null => true
  end
end
