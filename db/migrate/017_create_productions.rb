class CreateProductions < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :productions do |t|
      t.integer :order_id , :null => false
      t.integer :item_id  , :null => false
      t.integer :status_id  , :null => false
      t.integer :vote_no  , :null => false
      t.integer :branch1_no , :null => false
      t.integer :branch2_no , :null => false
      t.string  :customer_code  , :null => false  , :limit => 3
      t.string  :code , :null => false  , :limit => 4
      t.integer :result_amount
      t.date  :finish_ymd
      t.string  :comment
      t.integer :parts_fix_flag
      t.integer :print_flag , :null => false
      t.integer :summation_id
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end

    add_index :productions, [:vote_no, :branch1_no, :branch2_no], :unique => true
  end

  def self.down
    drop_table :productions
  end
end
