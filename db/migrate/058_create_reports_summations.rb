class CreateReportsSummations < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :reports_summations, :id => false do |t|
      t.references :summation  , :null => false
      t.references :report , :null => false
    end
  end

  def self.down
    drop_table :reports_summations
  end
end
