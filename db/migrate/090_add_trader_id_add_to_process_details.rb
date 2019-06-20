class AddTraderIdAddToProcessDetails < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :process_details, :trader_id, :integer
  end

  def self.down
    remove_column :process_details, :trader_id
  end
end
