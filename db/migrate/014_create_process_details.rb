class CreateProcessDetails < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :process_details do |t|
      t.integer :item_id  , :null => false
      t.integer :process_type_id  , :null => false
      t.string  :name
      t.string  :condition
      t.string  :model
      t.integer :hexavalent_flag
      t.integer :tanaka_flag
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end

    add_index :process_details, [:item_id, :process_type_id], :unique => true
  end

  def self.down
    drop_table :process_details
  end
end
