class ChangeDefectivenessAmountTypeToProductionDetails < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    change_column :production_details, :defectiveness_amount, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    change_column :production_details, :defectiveness_amount, :decimal
  end
end
