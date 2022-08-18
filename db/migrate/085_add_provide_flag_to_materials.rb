class AddProvideFlagToMaterials < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :materials, :provide_flag, :integer, :null => false
  end

  def self.down
    remove_column :materials, :provide_flag
  end
end
