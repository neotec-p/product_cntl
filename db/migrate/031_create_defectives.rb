class CreateDefectives < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :defectives do |t|
      t.integer :item_id  , :null => false
      t.string  :item_customer_code   , :limit => 3  , :null => false
      t.string  :item_code    , :limit => 4  , :null => false
      t.integer :model_id
      t.date    :outbreak_ymd , :null => false
      t.integer :defective_process_type_id  , :null => false
      t.string  :contents
      t.integer :amount
      t.decimal :weight , :precision => 10, :scale => 2
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :defectives
  end
end
