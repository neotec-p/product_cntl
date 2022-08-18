class AddProvideFlagToWashers < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :washers, :provide_flag, :integer, :null => false
  end

  def self.down
    remove_column :washers, :provide_flag
  end
end
