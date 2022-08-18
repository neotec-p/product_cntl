class AddSearchFlagToProcessTypes < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :process_types, :search_flag, :integer
  end

  def self.down
    remove_column :process_types, :search_flag
  end
end
