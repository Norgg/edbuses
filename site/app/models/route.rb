class Route < ActiveRecord::Base
  has_and_belongs_to_many :stops
  APIKEY = 'ABQIAAAA-8v5uQd8RR7pRFK1fhyysRT2yXp_ZAY8_ufC3CFXhHIE1NvwkxRq2rL2aX8A_YimdivOrCg_tla7CA'
  CENTER = 'Edinburgh'

  def self.scrape
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

  def get_stops_by_address(addr)
    url = 'http://maps.google.co.uk/maps/geo?q='+CGI.escape(addr+', '+CENTER)+'&output=xml&oe=utf8&sensor=true_or_false&key='+APIKEY
    doc = Nokogiri::XML(open(url))
    code = doc.search('code').inner_html
    if code=='200'
      data = doc.search('Placemark').first.search('coordinates').inner_html
      lng = data.split(',')[0]
      lat = data.split(',')[1]
      return get_nearby_stops(lat.to_f, lng.to_f)
    else
      return nil
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
