#!/usr/bin/ruby
require "open-uri"

class Stop
  attr_reader :id
  
  URL = "http://mobile.mybustracker.co.uk/wap.php?Navig=ResultStop1&busStopCodeQuick="

  def initialize(id)
    @id = id
  end

  def next_buses
    retstr = ""
    #p URL + @id
    page = open(URL+@id, "User-Agent" => "Wget/1.10.2"){|f| f.read}
    #p page

    page = page.split(/<\/table>/).join("</table>\n")
    tables = page.grep(/table/)
    #puts 'tables:'
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


def times *args
  stops=[]
  if (args[2] and not args[2].empty?) 
    args[2].split(" ").each{|id| stops << Stop.new(id)}
  else
    stops = [
             Stop.new("36245896"), #KB 41 stop.
             Stop.new("36237659")  #KB 24/42 stop.
            ]
  end
  stops.map{|stop| stop.next_buses}.join("\n")
end

puts times(ARGV.join(" "))

