class PositionsController < ApplicationController

  def index
    @date = begin
      Date.parse(params[:date])
    rescue
      if Position.count > 0
        Position.dates.first.date
      else
        Time.now.to_date
      end
    end
    @positions = Position.for_date(@date)
    @tweets = Tweet.for_date(@date)
  end

  def add
    pos = Position.add_from_gprmc(params[:id], params[:gprmc], params[:alt])
    if pos
      render text: "Ok #{pos.id}"
    else
      render text: 'Error'
    end
  end

end
