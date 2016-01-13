#!/usr/bin/python
# Disclaimer: This software is provided "As Is", without a warranty or
# support of any kind. The software is public-domain.
#
# This is an example of how to script downloads, see the
# "Configurable parameters" section below.

import os, sys, re, urllib, httplib
from xml.dom import minidom

#
# Configurable parameters
#
username = "ivanmbarbosa"		# replace with your login username
password = "hpnc8430"		# replace with your login password
station_name = "CUB"		# replace with station name, e.g. ASA, JSA, etc.
#
# End of Configurable parameters
#

hostname = "landsat.usgs.gov"

params = urllib.urlencode({'username': username, 'password': password});
headers = {"Content-type": "application/x-www-form-urlencoded"}
conn = httplib.HTTPSConnection(hostname)
conn.request("POST", "/up_login.php", params, headers)
response = conn.getresponse()
if response.status != 302:
	print "Invalid username/password"
	sys.exit(1)
cookie = response.getheader("Set-Cookie")
m = re.match("(landsat_up_private=\w+)", cookie)
session_id = m.group(1)
check_session = response.getheader("Location");

RSS = 'http://' + hostname + '/exchange_cache/' + station_name + '/outgoing/CCS/CCS.rss'
dom = minidom.parse(urllib.urlopen(RSS))
for item in dom.getElementsByTagName('item') :
	filename = ''
	downloadurl = ''
	for node in item.childNodes :
		if (node.nodeName == 'title') :
			for child in node.childNodes :
				if (child.nodeName == '#text') :
					filename = child.nodeValue
		if (node.nodeName == 'link') :
			for child in node.childNodes :
				if (child.nodeName == '#text') :
					downloadurl = child.nodeValue
	if (os.path.isfile(filename)) :
		print filename, " exists"
	else :
		curl_cmd = "curl -sSL -b " + session_id + " '" + downloadurl + "' > " + filename;
		print "Downloading " + filename
		os.system(curl_cmd);

