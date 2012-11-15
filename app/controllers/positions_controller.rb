class PositionsController < ApplicationController

  def home
    redirect_to positions_url(date: Position.dates.first.date.to_s)
  end

  def index
    date = Date.parse(params[:date])
    @positions = Position.for_date(date)
    @tweets = Tweet.for_date(date)
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
