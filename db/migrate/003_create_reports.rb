class CreateReports < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :reports do |t|
      t.integer :asynchro_status_id , :null => false
      t.integer :report_type_id
      t.string :file_name
      t.string :file_path
      t.string :disp_name
      t.string :content_type
      t.integer :size
      t.integer :user_id
      t.string :note
      t.integer :lock_version, :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end
end
