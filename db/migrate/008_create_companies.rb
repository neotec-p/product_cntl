class CreateCompanies < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :companies do |t|
      t.string  :name , :null => false
      t.string  :short_name , :null => false
      t.string  :zip_code , :null => false
      t.string  :address  , :null => false
      t.string  :tel  , :null => false
      t.string  :fax  , :null => false
      t.string  :product_dept , :null => false
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
