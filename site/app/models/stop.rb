class Stop < ActiveRecord::Base
  has_and_belongs_to_many :routes

  LIVE_TIMES_URL = "http://mobile.mybustracker.co.uk/wap.php?Navig=ResultStop1&busStopCodeQuick="

  def get_times(route)
    retstr = ""
    #p (LIVE_TIMES_URL + number.to_s)
    #p number.to_s
    page = open(LIVE_TIMES_URL + number.to_s, "User-Agent" => "Wget/1.10.2"){|f| f.read}
    #p page

    page = page.split(/<\/table>/).join("</table>\n")
    tables = page.grep(/table/)
    #puts 'tables:'
    #p tables
    #p tables
    tables.each do |table_src|
      table = table_src.match(/.*<table[^>]*>(.*)<\/table>.*/)[1]
      table.gsub!(/<\/?tr>/, " ")

      timetable = table.strip.split(/<\/?td>(<\/td>)?/)
      timetable.reject!{|s| s.empty?}

      (0..timetable.size).step(4) do |i|
        break if (i+3 > timetable.size)
        bus, dest, time, flags = timetable[i], timetable[i+1], timetable[i+2], timetable[i+3]
        time = time.split(/\s/).first
        
        #p [bus, dest, time]
        next unless bus == route
        
        retstr << "#{bus} to #{dest} "
        if (time == "DUE")
          retstr << "is due.\n" 
        elsif (time.match(/:/))
          retstr << "at #{time}.\n" 
        else
          retstr << "in #{time} minutes.\n"
        end
      end
    end
    retstr.strip
  end
end
