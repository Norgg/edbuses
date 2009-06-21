#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'net/pop'

$services = ['1','2','3','42']
$apikey = 'ABQIAAAA-8v5uQd8RR7pRFK1fhyysRT2yXp_ZAY8_ufC3CFXhHIE1NvwkxRq2rL2aX8A_YimdivOrCg_tla7CA'
$center='Edinburgh'
$keywords=['happy','smell','danger','kids','late','rude','unacceptable']

def fromTxt(q)
    q = q.split("--").first
    feedback = q.split.find{|string| $keywords.member? string}
    if feedback
        q=q.delete("bitch")
        comment = q.split()[1..-1].join(" ")   
        addComment(comment)
    else
        num = q.split.find{|string| $services.member? string}
        q=q.delete(num.to_s)
        addr = q.split()[1..-1].join(" ")    
        return GPSFromAddr(num,addr)
    end
end

def fromWeb(num,addr)
    return GPSFromAddr(num,addr)
end

def fromTweet(q)
    num = q.split.find{|string| $services.member? string}
    q=q.delete(num.to_s)
    addr = q.split()[1..-1].join(" ")
    return GPSFromAddr(num,addr)
end

def GPSFromAddr(route,addr)
    doc = Nokogiri::XML(
        open('http://maps.google.co.uk/maps/geo?q='+CGI.escape(addr+', '+$center)+'&output=xml&oe=utf8&sensor=true_or_false&key='+$apikey)
        )
    code = doc.search('code').inner_html
    if code=='200'

        data = doc.search('Placemark').first.search('coordinates').inner_html
        lng = data.split(',')[0]
        lat = data.split(',')[1]
        
        return [route, lat, lng]
    else
        return nil
    end
end


query="fixthebuses@gmail.com 42 Bruntsfield Pl -- Something else here"
info = fromTxt(query)

def getTexts()
    username = 'fixthebuses'
    password = 'glasgowispish'

    Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE)
    Net::POP3.start('pop.gmail.com', 995, username, password) do |pop|
      if pop.mails.empty?
        puts 'No mail.'
      else
        pop.each_mail do |mail|
          p mail.header
        end
      end
    end
    #return texts
end

getTexts()



