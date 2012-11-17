#!/usr/bin/env ruby

require 'open-uri'
require 'mysql2'
require 'yaml'
require 'twitter'

# Load app_config.yml
APP_CONFIG = YAML.load(File.read(File.expand_path('../config/app_config.yml', __FILE__)))
DB_CONFIG  = YAML.load(File.read(File.expand_path('../config/database.yml', __FILE__)))

class MyTweet
  def initialize(dbh)
    @dbh = dbh
    Twitter.configure do |config|
      config.consumer_key       = APP_CONFIG['twitter']['consumer_key']
      config.consumer_secret    = APP_CONFIG['twitter']['consumer_secret']
      config.oauth_token        = APP_CONFIG['twitter']['oauth_token']
      config.oauth_token_secret = APP_CONFIG['twitter']['oauth_token_secret']
    end
  end

  def fetch_tweets
    num_inserted = 0
    tweets = Twitter.user_timeline(APP_CONFIG['twitter']['username'], since_id: last_id)
    tweets.reverse.each do |tweet|
      if tweet.geo
        insert_tweet tweet
        num_inserted += 1
      end
    end
    num_inserted
  end

  private

  def last_id
    sql = <<-SQL
      SELECT * from tweets
      ORDER BY datetime DESC
      LIMIT 1
    SQL
    last_tweet = @dbh.query(sql).first
    last_tweet ? last_tweet['tweet_id'] : '254228976095072257'
  end

  def insert_tweet(tweet)
    sql = <<-SQL
      INSERT INTO tweets(tweet_id, text, tweet_url, picture_url, latitude, longitude, datetime)
      VALUES(
        '#{tweet.id}',
        '#{@dbh.escape tweet.text}',
        'https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}',
        '#{tweet.media.first ? tweet.media.first.media_url : ""}',
        #{tweet.geo.lat},
        #{tweet.geo.lng},
        '#{tweet.created_at.utc.strftime("%F %T")}'
      )
    SQL
    @dbh.query sql
  end
end

dbh = Mysql2::Client.new(
  :host => '127.0.0.1',
  :port => 3306,
  :database => DB_CONFIG['production']['database'],
  :username => DB_CONFIG['production']['username'],
  :password => DB_CONFIG['production']['password'],
)

my_tweets = MyTweet.new(dbh)
num_tweets = my_tweets.fetch_tweets
puts "#{num_tweets} new tweets#{num_tweets != 1 ? 's' : ''} inserted."
