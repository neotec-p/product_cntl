class CreateUsers < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :users do |t|
      t.string  :login_id , :null => false, :limit => 3
      t.string  :hashed_password
      t.string  :salt
      t.datetime :password_updated,:after => :salt
      t.string  :last_name  , :limit => 50
      t.string  :first_name  , :limit => 50
      t.integer :role_id, :null => false
      t.integer :lock_version , :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
