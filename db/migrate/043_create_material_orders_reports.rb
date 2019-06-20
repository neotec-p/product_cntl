class CreateMaterialOrdersReports < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :material_orders_reports, :id => false do |t|
      t.references :material_order  , :null => false
      t.references :report , :null => false
    end
  end

  def self.down
    drop_table :material_orders_reports
  end
end
