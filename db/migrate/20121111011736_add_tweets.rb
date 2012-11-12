class AddTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string  :tweet_id
      t.string  :text
      t.string  :tweet_url
      t.string  :picture_url
      t.integer :timestamp
      t.decimal :latitude,  precision: 11, scale: 6
      t.decimal :longitude, precision: 11, scale: 6
    end

    add_index :tweets, :tweet_id
    add_index :tweets, :timestamp
  end
end
