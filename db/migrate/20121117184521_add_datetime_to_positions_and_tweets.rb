class AddDatetimeToPositionsAndTweets < ActiveRecord::Migration
  def change
    add_column :positions, :datetime, :datetime
    add_column :tweets,    :datetime, :datetime
    add_index  :positions, :datetime
    add_index  :tweets,    :datetime
  end
end
