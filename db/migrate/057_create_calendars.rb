class CreateCalendars < ActiveRecord::Migration[4.2][4.2][4.2]
  def self.up
    create_table :calendars do |t|
      t.integer :year , :null => false
      t.integer :month  , :null => false
      t.integer :day  , :null => false
      t.string :holiday
      t.integer :lock_version , :null => false    , :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :calendars
  end
end
