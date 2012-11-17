class RemoveTimestamps < ActiveRecord::Migration
  def up
    remove_column :positions, :timestamp
    remove_column :positions, :device_name
    remove_column :tweets,    :timestamp
  end

  def down
  end
end
