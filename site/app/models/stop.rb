class Stop < ActiveRecord::Base
  has_and_belongs_to_many :routes

  LIVE_TIMES_URL = "http://mobile.mybustracker.co.uk/wap.php?Navig=ResultStop1&busStopCodeQuick="

  def times
    #TODO: Use some real XML parsing.
    times = []
    page = open(LIVE_TIMES_URL + number.to_s, "User-Agent" => "Wget/1.10.2"){|f| f.read}

    page = page.split(/<\/table>/).join("</table>\n")
    tables = page.grep(/table/)
    tables.each do |table_src|
      table = table_src.match(/.*<table[^>]*>(.*)<\/table>.*/)[1]
      table.gsub!(/<\/?tr>/, " ")

      timetable = table.strip.split(/<\/?td>(<\/td>)?/)
      timetable.reject!{|s| s.empty?}

      (0..timetable.size).step(4) do |i|
        break if (i+3 > timetable.size)
        route, dest, time, flags = timetable[i], timetable[i+1], timetable[i+2], timetable[i+3]
        time = time.split(/\s/).first
        
        time_hash = {:route => route, :dest => dest}
        times << time_hash
        if (time == "DUE")
          time_hash[:time] = "is due"
        elsif (time.match(/:/))
          time_hash[:time] = "at #{time}"
        else
          time_hash[:time] = "in #{time} minutes"
        end
      end
    end
    times
  end

  def self.find_by_address(addr, num=4)
    url = 'http://maps.google.co.uk/maps/geo?q='+CGI.escape(addr+', '+CENTER)+'&output=xml&oe=utf8&sensor=true_or_false&key='+APIKEY
    doc = Nokogiri::XML(open(url))
    code = doc.search('code').inner_html
    if code=='200'
      data = doc.search('Placemark').first.search('coordinates').inner_html
      lng = data.split(',')[0]
      lat = data.split(',')[1]
      return get_nearby_stops(lat.to_f, lng.to_f, num)
    else
      return nil
    end
  end

  def self.get_nearby_stops(lat, lng, num=4)
    stops_with_distance = find(:all).map do |stop|
      [(lat-stop.lat)**2 + (lng-stop.lng)**2, stop]
    end
    sorted_stops = stops_with_distance.sort{|a, b| a.first <=> b.first}.map{|tuple| tuple.last}
    sorted_stops[0...num]
  end

end
