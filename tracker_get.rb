#!/usr/bin/env ruby

require 'open-uri'
require 'mysql2'
require 'yaml'

# Load app_config.yml
APP_CONFIG = YAML.load(File.read(File.expand_path('../config/app_config.yml', __FILE__)))
DB_CONFIG  = YAML.load(File.read(File.expand_path('../config/database.yml', __FILE__)))

class Tracker
  def initialize
    @dbh = Mysql2::Client.new(
      :host => '127.0.0.1',
      :port => 3306,
      :database => DB_CONFIG['production']['database'],
      :username => DB_CONFIG['production']['username'],
      :password => DB_CONFIG['production']['password'],
    )
  end

  def fetch_positions
    num_inserted = 0
    open url(last_timestamp) do |f|
      f.each_line do |line|
        dkey, dname, ts, lat, lng, alt, speed, heading = line.chomp.split(',')
        if ts
          insert_positions(
            dkey:    dkey,
            dname:   dname,
            ts:      ts,
            lat:     lat,
            lng:     lng,
            alt:     alt,
            speed:   speed,
            heading: heading
          )
          num_inserted += 1
        end
      end
    end
    num_inserted
  end

  private

  def url(from_ts)
    "http://www.instamapper.com/api?action=getPositions&key=#{APP_CONFIG['instamapper']['key']}&num=100&from_ts=#{from_ts+1}"
  end

  def last_timestamp
    sql = <<-SQL
      SELECT * from positions
      ORDER BY timestamp DESC
      LIMIT 1
    SQL
    last_position = @dbh.query(sql).first
    last_position ? last_position['timestamp'] : 0
  end

  def insert_positions(args)
    sql = <<-SQL
      INSERT INTO positions(device_key, device_name, timestamp, latitude, longitude, altitude, speed, heading)
      VALUES(
        '#{args[:dkey]}',
        '#{args[:dname]}',
        '#{args[:ts].to_i}',
        '#{args[:lat].to_f}',
        '#{args[:lng].to_f}',
        '#{args[:alt].to_f}',
        '#{args[:speed].to_f}',
        '#{args[:heading].to_i}'
      )
    SQL
    @dbh.query sql
  end

end

num_positions = Tracker.new.fetch_positions
puts "#{num_positions} new position#{num_positions != 1 ? 's' : ''} inserted."
