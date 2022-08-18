class CreateAsynchroStatuses < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :asynchro_statuses do |t|
      t.string  :name , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :asynchro_statuses
  end
end
