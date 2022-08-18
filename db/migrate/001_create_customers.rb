class CreateCustomers < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :customers do |t|
      t.string :code         ,:limit => 3
      t.string :name         ,:limit => 50
      t.string :note
      t.integer :lock_version, :null => false, :default => 0

      t.timestamps
    end
    
    add_index :customers, [:code], :unique => true
  end

  def self.down
    drop_table :customers
  end
end
