class CreateRoles < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :roles do |t|
      t.string  :name , :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end
