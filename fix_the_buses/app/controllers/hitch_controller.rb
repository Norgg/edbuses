class HitchController < ApplicationController
  def index
  end

  def lookup
    if params[:hitch]
      @route_str = params[:hitch][:route]
      @route = Route.find_by_number(@route_str)
      if @route
        @stops = @route.get_stops_by_address(params[:hitch][:from_location])
        @stops = @stops[0..1] if @stops
        @times_str = @stops.map{|stop| stop.get_times(@route_str)} if @stops
      end
    end
  end
end
