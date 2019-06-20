class RemoveExpenseFromItems < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    remove_column :items, :expense
  end

  def self.down
    add_column :items, :expense, :decimal
  end
end
