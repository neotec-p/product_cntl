class CreateDefectiveProcessTypes < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :defective_process_types do |t|
      t.string  :name
      t.integer :seq, :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :defective_process_types
  end
end
