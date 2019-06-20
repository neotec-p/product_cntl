class CreateSummationTypes < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :summation_types do |t|
      t.string  :name , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :summation_types
  end
end
