class CreateSummations < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :summations do |t|
      t.integer :summation_type_id , :null => false
      t.integer :asynchro_status_id , :null => false
      t.date  :target_ymd , :null => false
      t.integer :user_id  , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :summations
  end
end
