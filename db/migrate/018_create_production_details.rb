class CreateProductionDetails < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :production_details do |t|
      t.integer :production_id  , :null => false
      t.integer :process_detail_id  , :null => false
      t.integer :model_id
      t.date  :plan_start_ymd
      t.date  :plan_end_ymd
      t.date  :result_start_ymd
      t.date  :result_end_ymd
      t.decimal :result_amount_production
      t.decimal :result_amount_history
      t.decimal :defectiveness_amount
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end

    add_index :production_details, [:production_id, :process_detail_id], :unique => true
  end

  def self.down
    drop_table :production_details
  end
end
