class HitchController < ApplicationController
  def lookup
    if params[:from]
      @stops = Stop.find_by_address(params[:from], 2)
      @place = params[:from]
    end
  end
end
