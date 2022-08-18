class AddLogicalWeightFlagToItem < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :items, :logical_weight_flag, :integer
  end

  def self.down
    remove_column :items, :logical_weight_flag
  end
end
