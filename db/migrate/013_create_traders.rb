class CreateTraders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :traders do |t|
      t.string  :type , :null => false
      t.string  :name , :null => false
      t.string  :zip_code
      t.string  :address
      t.string  :tel
      t.string  :fax
      t.integer :lock_version , :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :traders
  end
end
