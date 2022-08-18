class AddCollectFlagToMaterialStocks < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :washer_stocks, :collect_flag, :integer, :null => false
  end

  def self.down
    remove_column :washer_stocks, :collect_flag
  end
end
