class Gprmc
  attr_reader :datetime, :latitude, :longitude, :speed, :bearing

  def initialize(gprmc_str)
    @valid = false
    fields = gprmc_str.split(',')
    return if fields.size != 12
    return if fields[0] != '$GPRMC'
    return if fields[2] != 'A'
    @datetime  = date_time_to_date(fields[9], fields[1])
    @latitude  = latlng_to_f(fields[3], fields[4] == 'S')
    @longitude = latlng_to_f(fields[5], fields[6] == 'W')
    @speed     = fields[7].to_f * 1.852 # knots to mps
    @bearing   = fields[8].to_i
    @valid = true
  end

  def valid?
    @valid
  end

  private

  def date_time_to_date(date, time)
    time.gsub!(/\.[0-9]*$/, "") # remove decimals
    datetime = "#{date} #{time} UTC"
    DateTime.strptime(datetime, "%d%m%y %H%M%S %Z")
  end

  # Convert a Lat or Long NMEA coordinate to decimal
  def latlng_to_f(coord, negative = false)
    decimal = nil

    if coord =~ /^([0-9]*?)([0-9]{2,2}\.[0-9]*)$/
      deg = $1.to_i # degrees
      min = $2.to_f # minutes & seconds

      # Calculate
      decimal = deg + (min / 60)
      if negative
        decimal *= -1
      end
    end

    decimal
  end

end
