class ChangePriceTypeToProcessPrices < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :process_prices, :price, :decimal, :precision => 10, :scale => 3  , :null => false
  end

  def self.down
    change_column :process_prices, :price, :decimal, :precision => 10, :scale => 2  , :null => false
  end
end
