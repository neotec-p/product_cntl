class AddExpenseSumCategoryToProcessType < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :process_types, :expense_sum_category, :integer
  end

  def self.down
    remove_column :process_types, :expense_sum_category
  end
end
