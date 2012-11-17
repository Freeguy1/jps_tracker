require 'gprmc'

class Position < ActiveRecord::Base

  class << self
    def add_from_gprmc(id, gprmc, altitude)
      gpsdata = Gprmc.new gprmc
      if gpsdata.valid?
        existing = Position.where(device_key: id, datetime: gpsdata.datetime).first
        if existing
          position = existing
        else
          position = new
          position.device_key = id
          position.altitude   = altitude
          position.heading    = gpsdata.bearing
          position.latitude   = gpsdata.latitude
          position.longitude  = gpsdata.longitude
          position.speed      = gpsdata.speed
          position.datetime   = gpsdata.datetime
          position.save
        end
      end
      position
    end

    def dates
      select('distinct(DATE(datetime)) AS date').order('date DESC')
    end

    def for_date(date)
      select('datetime, latitude, longitude, altitude, speed, heading').
      where('datetime <= ? AND datetime >= ?',
        date.end_of_day, date.beginning_of_day).
      order('datetime ASC')
    end
  end
end
