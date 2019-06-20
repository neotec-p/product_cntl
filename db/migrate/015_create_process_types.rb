class CreateProcessTypes < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :process_types do |t|
      t.string  :name , :null => false
      t.integer :protected_flag
      t.integer :ratio_flag
      t.integer :plan_process_flag
      t.integer :processor_flag
      t.integer :barrel_flag
      t.integer :seq, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :process_types
  end
end
