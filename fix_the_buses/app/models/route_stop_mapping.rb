class RouteStopMapping < ActiveRecord::Base
  has_one :route
  has_one :stop
end
