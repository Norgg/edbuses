import urllib
from xml.dom import minidom
services = [1,2,3,42]
query="fixthebuses@gmail.com 42 Glasgow caledonian university -- Something else here"
apikey = 'ABQIAAAA-8v5uQd8RR7pRFK1fhyysRT2yXp_ZAY8_ufC3CFXhHIE1NvwkxRq2rL2aX8A_YimdivOrCg_tla7CA'

def GPSfromTxt(q):
    q = q.split("--")
    q = q[0]
    positions = [q.find(str(s)) for s in services]
    num = [p for p in positions if p > -1]
    num=num[0]
    req=q
    
    f = urllib.urlopen('http://maps.google.co.uk/maps/geo?q='+req+'&output=xml&oe=utf8&sensor=true_or_false&key='+apikey)
    xmldata = minidom.parse(f)
    
    status = xmldata.getElementsByTagName('Status')[0].getElementsByTagName('code')[0].firstChild.toxml()
    if status==200: #success
        [lng,lat,_] = xmldata.getElementsByTagName('Placemark')[0].getElementsByTagName('coordinates')[0].firstChild.toxml().split(',')
        #address = xmldata.getElementsByTagName('Placemark')[0].getElementsByTagName('address')[0].firstChild.toxml().split(',')
        return [num,lng, lat]
    else:
        raise Exception('Did not understand the query')
   
   
[service,lng,lat] = GPSfromTxt(query)
