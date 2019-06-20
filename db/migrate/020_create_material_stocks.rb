class CreateMaterialStocks < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :material_stocks do |t|
      t.integer :material_id  , :null => false
      t.integer :material_order_id  , :null => false
      t.string  :inspection_no
      t.decimal :accept_weight , :precision => 10, :scale => 2  , :null => false
      t.date  :accept_ymd , :null => false
      t.decimal :adjust_weight , :precision => 10, :scale => 2
      t.integer :print_flag  , :null => false
      t.integer :collect_flag  , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :material_stocks
  end
end
