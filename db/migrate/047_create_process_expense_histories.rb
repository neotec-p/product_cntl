class CreateProcessExpenseHistories < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :process_expense_histories do |t|
      t.integer :process_expense_id, :null => false
      t.integer :item_id , :null => false
      t.decimal :hd , :precision => 5, :scale => 3 
      t.decimal :barrel , :precision => 5, :scale => 3 
      t.decimal :hd_addition , :precision => 5, :scale => 3  
      t.decimal :ro1 , :precision => 5, :scale => 3  
      t.decimal :ro1_addition , :precision => 5, :scale => 3 
      t.decimal :ro2 , :precision => 5, :scale => 3  
      t.decimal :ro2_addition , :precision => 5, :scale => 3 
      t.decimal :heat , :precision => 5, :scale => 3 
      t.decimal :heat_addition , :precision => 5, :scale => 3 
      t.decimal :surface , :precision => 5, :scale => 3  
      t.decimal :surface_addition , :precision => 5, :scale => 3 
      t.decimal :inspection , :precision => 5, :scale => 3 
      t.decimal :inspection_addition , :precision => 5, :scale => 3 
      t.decimal :ratio_hd , :precision => 5, :scale => 3 
      t.decimal :ratio_barrel , :precision => 5, :scale => 3 
      t.decimal :ratio_ro1 , :precision => 5, :scale => 3  
      t.decimal :ratio_ro2 , :precision => 5, :scale => 3
      t.decimal :ratio_heat , :precision => 5, :scale => 3
      t.decimal :ratio_surface , :precision => 5, :scale => 3
      t.date  :start_ymd  , :null => false
      t.date  :end_ymd  , :null => false
      t.date  :created_ymd  , :null => false
      t.integer :lock_version , :null => false    , :default => 0
      
      t.timestamps
    end
    
    add_index :process_expense_histories, [:item_id, :start_ymd, :end_ymd], :unique => true, :name => :index_process_expense_histories_u
  end
  
  def self.down
    drop_table :process_expense_histories
  end
end
