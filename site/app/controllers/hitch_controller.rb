class HitchController < ApplicationController
  def index
  end

  def lookup
    if params[:hitch]
      @stops = Stop.find_by_address(params[:hitch][:from_location], 2)
      @place = params[:hitch][:from_location]
    end
  end
end
