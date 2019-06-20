class ChangeWeightTypeToLots < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :lots, :weight, :decimal, :precision => 10, :scale => 1  , :null => true
  end

  def self.down
    change_column :lots, :weight, :decimal, :precision => 10, :scale => 2  , :null => true
  end
end
