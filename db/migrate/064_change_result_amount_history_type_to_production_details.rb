class ChangeResultAmountHistoryTypeToProductionDetails < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :production_details, :result_amount_history, :integer
  end

  def self.down
    change_column :production_details, :result_amount_history, :decimal
  end
end
