class AddOrderToReportTypes < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :report_types, :seq, :integer, :null => false
  end

  def self.down
    remove_column :report_types, :seq
  end
end
