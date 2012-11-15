require 'gprmc'

class Position < ActiveRecord::Base

  class << self
    def add_from_gprmc(id, gprmc, altitude)
      gpsdata = Gprmc.new gprmc
      if gpsdata.valid?
        existing = Position.where(device_key: id, timestamp: gpsdata.datetime.to_i).first
        if existing
          position = existing
        else
          position = new
          position.device_key = id
          position.altitude   = altitude
          position.timestamp  = gpsdata.datetime
          position.heading    = gpsdata.bearing
          position.latitude   = gpsdata.latitude
          position.longitude  = gpsdata.longitude
          position.speed      = gpsdata.speed
          position.save
        end
      end
      position
    end

    def dates
      select('distinct(DATE(FROM_UNIXTIME(timestamp))) AS date').order('date DESC')
    end

    def for_date(date)
      select('timestamp, latitude, longitude, altitude, speed, heading').
      where('timestamp <= UNIX_TIMESTAMP(?) AND timestamp >= UNIX_TIMESTAMP(?)',
        date.end_of_day, date.beginning_of_day).
      order('timestamp ASC')
    end
  end
end
