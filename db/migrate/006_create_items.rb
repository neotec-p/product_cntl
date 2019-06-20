class CreateItems < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :items do |t|
      t.integer :customer_id  , :null => false
      t.string  :customer_code  , :null => false  , :limit => 3
      t.string :code, :null => false  , :limit => 4
      t.string :drawing_no, :null => false
      t.string :name, :null => false
      t.decimal :price, :null => false  , :precision => 10, :scale => 2
      t.decimal :weight  , :precision => 10, :scale => 6
      t.string :punch
      t.decimal :expense  , :precision => 10, :scale => 2
      t.string  :hd_model_name1
      t.string  :hd_model_name2
      t.string  :hd_model_name3
      t.string  :ro1_model_name1
      t.string  :ro1_model_name2
      t.string  :ro1_model_name3
      t.string  :ro2_model_name1
      t.string  :ro2_model_name2
      t.string  :ro2_model_name3
      t.string  :hd_addition_model_name
      t.string  :ro1_addition_model_name
      t.string  :ro2_addition_model_name
      t.string :vote_note
      t.string :surface_note
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end

    add_index :items, [:customer_code, :code], :unique => true
  end

  def self.down
    drop_table :items
  end
end
