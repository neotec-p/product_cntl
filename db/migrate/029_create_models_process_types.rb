class CreateModelsProcessTypes < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :models_process_types, :id => false do |t|
      t.references :model  , :null => false
      t.references :process_type , :null => false
    end
  end

  def self.down
    drop_table :models_process_types
  end
end
