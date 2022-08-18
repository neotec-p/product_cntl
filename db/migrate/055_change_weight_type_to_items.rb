class ChangeWeightTypeToItems < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :items, :weight, :decimal, :precision => 10, :scale => 6  , :null => false
  end

  def self.down
    change_column :items, :weight, :decimal, :precision => 10, :scale => 6
  end
end
