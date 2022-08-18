class AddIndexToProductionDetails < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_index :production_details, [:model_id], :unique => false
  end

  def self.down
    remove_index :production_details, :column => :model_id
  end
end
