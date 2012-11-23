require 'gprmc'

class Position < ActiveRecord::Base

  class << self
    def add_from_gprmc(id, gprmc, altitude)
      gpsdata = Gprmc.new gprmc
      if gpsdata.valid?
        position = Position.where(device_key: id, datetime: gpsdata.datetime).first_or_create do |pos|
          pos.altitude   = altitude
          pos.heading    = gpsdata.bearing
          pos.latitude   = gpsdata.latitude
          pos.longitude  = gpsdata.longitude
          pos.speed      = gpsdata.speed
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
