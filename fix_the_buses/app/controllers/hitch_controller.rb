class HitchController < ApplicationController
  def index
  end

  def lookup
    @params_disp = params
    @route_str = params[:hitch][:route]
    @route = Route.find_by_number(@route_str)
    @stops = @route.get_stops_by_address(params[:hitch][:from_location])[0..1]
    @times_str = @stops.map{|stop| stop.get_times(@route_str)}
  end
end
