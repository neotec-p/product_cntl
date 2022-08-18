class ChangeColumnsForProcessExpenses < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :process_expenses, :hd, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :barrel, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :hd_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :ro1, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :ro1_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :ro2, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :ro2_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :heat, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :heat_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :surface, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :surface_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :inspection, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expenses, :inspection_addition, :decimal, :precision => 10, :scale => 3, :null => true
  end

  def self.down
    change_column :process_expenses, :hd, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :barrel, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :hd_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :ro1, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :ro1_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :ro2, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :ro2_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :heat, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :heat_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :surface, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :surface_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :inspection, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expenses, :inspection_addition, :decimal, :precision => 5, :scale => 3, :null => true
  end
end
