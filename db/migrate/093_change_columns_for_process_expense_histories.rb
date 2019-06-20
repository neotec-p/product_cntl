class ChangeColumnsForProcessExpenseHistories < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :process_expense_histories, :hd, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :barrel, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :hd_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :ro1, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :ro1_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :ro2, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :ro2_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :heat, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :heat_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :surface, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :surface_addition, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :inspection, :decimal, :precision => 10, :scale => 3, :null => true
    change_column :process_expense_histories, :inspection_addition, :decimal, :precision => 10, :scale => 3, :null => true
  end

  def self.down
    change_column :process_expense_histories, :hd, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :barrel, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :hd_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :ro1, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :ro1_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :ro2, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :ro2_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :heat, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :heat_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :surface, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :surface_addition, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :inspection, :decimal, :precision => 5, :scale => 3, :null => true
    change_column :process_expense_histories, :inspection_addition, :decimal, :precision => 5, :scale => 3, :null => true
  end
end
