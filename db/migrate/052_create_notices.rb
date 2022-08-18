class CreateNotices < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :notices do |t|
      t.integer :user_id  , :null => false    
      t.string  :contents , :null => false    
      t.date  :created_ymd , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :notices
  end
end
