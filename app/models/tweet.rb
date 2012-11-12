class Tweet < ActiveRecord::Base

  class << self
    def for_date(date)
      where('timestamp <= UNIX_TIMESTAMP(?) AND timestamp >= UNIX_TIMESTAMP(?)',
        date.end_of_day, date.beginning_of_day).
      order('timestamp ASC')
    end
  end
end
