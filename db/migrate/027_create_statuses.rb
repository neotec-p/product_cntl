class CreateStatuses < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :statuses do |t|
      t.string  :name   , :limit => 20
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :statuses
  end
end
