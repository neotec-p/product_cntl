class RemoveAmountFromLot < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    remove_column :lots, :amount
  end

  def self.down
    add_column :lots, :amount, :integer
  end
end
