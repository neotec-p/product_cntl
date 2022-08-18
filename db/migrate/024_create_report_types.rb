class CreateReportTypes < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :report_types do |t|
      t.string  :code , :null => false
      t.string  :name , :null => false
      t.string  :dt_format

      t.timestamps
    end

    add_index :report_types, [:code], :unique => true
  end

  def self.down
    drop_table :report_types
  end
end
