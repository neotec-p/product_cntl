class AddColumnsForTraders < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    add_column :traders, :addition_attr1, :string
    add_column :traders, :addition_attr2, :string
    add_column :traders, :addition_attr3, :string
    add_column :traders, :addition_attr4, :string
    add_column :traders, :addition_attr5, :string
  end

  def self.down
    remove_column :traders, :addition_attr1
    remove_column :traders, :addition_attr2
    remove_column :traders, :addition_attr3
    remove_column :traders, :addition_attr4
    remove_column :traders, :addition_attr5
  end
end
