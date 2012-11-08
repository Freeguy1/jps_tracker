class PositionsController < ApplicationController

  def home
    redirect_to positions_url(date: Position.dates.first.date.to_s)
  end

  def index
    date = Date.parse(params[:date])
    @positions = Position.for_date(date)
  end

end
