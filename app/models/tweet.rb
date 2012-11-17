class Tweet < ActiveRecord::Base

  class << self
    def for_date(date)
      where('datetime <= ? AND datetime >= ?',
        date.end_of_day, date.beginning_of_day).
      order('datetime ASC')
    end
  end
end
