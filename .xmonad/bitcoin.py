#!/usr/bin/python
import json
import urllib2

dict = json.loads(urllib2.urlopen("https://coinbase.com/api/v1/prices/spot_rate").read())
print("%.2f" % float(dict["amount"]))
