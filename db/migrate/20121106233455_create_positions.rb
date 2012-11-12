class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string  :device_key
      t.string  :device_name
      t.integer :timestamp
      t.integer :heading
      t.decimal :latitude,  precision: 11, scale: 6
      t.decimal :longitude, precision: 11, scale: 6
      t.decimal :altitude,  precision: 11, scale: 6
      t.decimal :speed,     precision: 5,  scale: 2
    end

    add_index :positions, :timestamp
  end
end
