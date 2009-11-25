#!/home/norgg/fix_the_buses/fix_the_buses/script/runner

require 'tmail'
require 'cgi'

$services = Route.all.map{|r| r.number.to_s}
p $services
$keywords=['happy','smell','danger','kids','late','rude','unacceptable']

def get_texts
    username = 'fixthebuses'
    password = 'glasgowispish'
    texts = []

    Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE)
    Net::POP3.start('pop.gmail.com', 995, username, password) do |pop|
      if pop.mails.empty?
        print "."
        $stdout.flush
      else
        pop.each_mail do |raw_email|
    email = TMail::Mail.parse(raw_email.pop)
          texts << [email.from, email.body]
        end
      end
    end
    #p texts
    return texts
end

def from_txt(from, q)
  p from
  dest = from.first.split('@').first
  q = q.split("--").first
  feedback = q.split.find{|string| $keywords.member? string}
  if feedback
    comment = q.split()[1..-1].join(" ")
    puts comment
    puts feedback
#    addComment(feedback, comment)
  else
    num = q.split.find{|string| $services.member? string}
    q=q.sub(num.to_s,"")
    #addr = q.split()[1..-1].join(" ")
    addr = q
      route = Route.find_by_number(num)
    p addr
    txt_string = ""
    if (route.nil?)
      txt_string = "So very sorry, couldn't handle your request."
    else
      stops = route.get_stops_by_address(addr)
      stops[0..1].each{|stop| txt_string << stop.name + " "; txt_string << stop.get_times(num)}
    end
    puts txt_string
    txt_string = txt_string.gsub("\n", "  ")
    txt_string = txt_string.gsub(" ", "%20")
    url = "http://sms.gladserv.com/sms/sms.cgi?username=sicamp&password=sicamp&destination=#{dest}&message=#{txt_string}"
    p url
    p open(url).read
  end
end

while(true)
  get_texts.each{|text_info| from_txt(*text_info)}
  sleep(30)
end
#from_txt(["+447540844574@sms.aaisp.net.uk"], "blah@blah.blah 24 King's Buildings")

