class CreateLots < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :lots do |t|
      t.integer :production_id  , :null => false
      t.integer :lot_no , :null => false
      t.integer :amount
      t.decimal :weight , :precision => 10, :scale => 2
      t.integer :case
      t.date  :insert_ymd , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end

    add_index :lots, [:lot_no], :unique => true
  end

  def self.down
    drop_table :lots
  end
end
