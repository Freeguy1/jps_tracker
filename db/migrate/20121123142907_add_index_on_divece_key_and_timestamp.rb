class AddIndexOnDiveceKeyAndTimestamp < ActiveRecord::Migration
  def up
    add_index :positions, [:datetime, :device_key]
    remove_index :positions, :datetime
  end

  def down
  end
end
