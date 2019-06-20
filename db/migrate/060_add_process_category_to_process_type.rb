class AddProcessCategoryToProcessType < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :process_types, :process_category, :integer
  end

  def self.down
    remove_column :process_types, :process_category
  end
end
