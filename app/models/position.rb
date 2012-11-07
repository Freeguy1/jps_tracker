class Position < ActiveRecord::Base
  
  class << self
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
