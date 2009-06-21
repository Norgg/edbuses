class Route < ActiveRecord::Base
  has_and_belongs_to_many :stops

  def self.scrape
    require 'nokogiri'
    require 'open-uri'

    doc = Nokogiri::HTML(open("http://www.mybustracker.co.uk/index.php?display=Service"))
    routes = []
    doc.search("select#serviceService", "option").each do |route_opt|
      route = route_opt.inner_html.split.first
      routes << route
    end
    
    routes.shift #Get rid of the "<option" that sneaks in here.
    p routes

    routes.each do |route_str|
      route = Route.new(:number => route_str)
      route.save!

      print "Adding stops to route: #{route_str}..."

      route_doc = Nokogiri::XML(open("http://mybustracker.co.uk/getServicePoints.php?serviceMnemo=#{route_str}"))

      stops = route_doc.search("map", "markers/busStop")
      stops.shift #Again, extra stuff at the start for some reason.

      stops.each do |stop|
        args = {}
        args[:number] = (stop.search("sms")).inner_html
        args[:name] = (stop.search("nom")).inner_html
        args[:lat] = (stop.search("x")).inner_html
        args[:lng] = (stop.search("y")).inner_html
        stop = Stop.new(args)
        stop.save
        route.stops << stop
      end
      route.save

      puts " done."
    end
  end

  def get_nearby_stops(lat, lng)
    stops_with_distance = stops.map do |stop|
      [(lat-stop.lat)**2 + (lng-stop.lng)**2, stop]
    end
    sorted_stops = stops_with_distance.sort{|a, b| a.first <=> b.first}.map{|tuple| tuple.last}
    sorted_stops
  end
end
