#!/usr/bin/python
# Disclaimer: This software is provided "As Is", without a warranty or
# support of any kind. The software is public-domain.
#
# This is an example of how to script downloads, see the
# "Configurable parameters" section below.

import os, urllib, getopt, sys
from xml.dom import minidom

# Configurable parameters
RSS = 'http://landsat.usgs.gov/bpf.rss'
# Use 'http://landsat.usgs.gov/cpf.rss' for CPFs
# End of Configurable parameters

# Run time options:
#	-n #	to limit the number of files (default is unlimited)
#	-u url	set the URL for the RSS feed
maxfiles = 0
opts, args = getopt.getopt(sys.argv[1:], "u:n:")
for o, a in opts:
	if o == '-u':
		RSS = a
	elif o == '-n':
		maxfiles = int(a)
	else:
		print "Bad option: ", o

nfiles = 0
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
		curl_cmd = "curl -sSL '" + downloadurl + "' > " + filename;
		print "Downloading " + filename
		os.system(curl_cmd);
		nfiles = nfiles + 1
		if (maxfiles > 0) and (nfiles >= maxfiles):
			break

