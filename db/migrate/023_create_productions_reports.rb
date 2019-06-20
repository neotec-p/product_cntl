class CreateProductionsReports < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :productions_reports, :id => false do |t|
      t.references :production  , :null => false
      t.references :report , :null => false
    end
  end

  def self.down
    drop_table :productions_reports
  end
end
