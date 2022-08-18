class CreateMaterialStocksReports < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :material_stocks_reports, :id => false do |t|
      t.references :material_stock  , :null => false
      t.references :report , :null => false
    end
  end

  def self.down
    drop_table :material_stocks_reports
  end
end
