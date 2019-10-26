#!/usr/bin/env python
"""Get dynamic inventory in JSON format.
Usage:

  \033[1m-h\033[0m, \033[1m--help\033[0m                Print this message
  \033[1m-l\033[0m, \033[1m--list\033[0m                Print inventory in JSON format
  \033[1m--host\033[0m \033[4minstance_name\033[0m      Print detailed info on instance instance_name
"""

import sys
import getopt
import json
import requests

PROJECT_ID = 'PLACE-PROJECT-ID-HERE'
ZONE_ID = 'PLACE-ZONE-ID-HERE'
TOKEN = 'Bearer PLACE-TOKEN-HERE'

headers = {'Content-type': 'application/json; charset=utf-8', 'Authorization': TOKEN}

def fetch_instance(INSTANCE):
    url = 'https://compute.googleapis.com/compute/v1/projects/%s/zones/%s/instances/%s' % (PROJECT_ID, ZONE_ID, INSTANCE)
    r = requests.get(url, headers=headers)
    return r.json()

def fetch_inventory():
    url = 'https://compute.googleapis.com/compute/v1/projects/%s/zones/%s/instances' % (PROJECT_ID, ZONE_ID)
    r = requests.get(url, headers=headers)
    
    inventory = {
        "_meta": {
            "hostvars": {
                instance['name']:{'ansible_host': instance['networkInterfaces'][0]['accessConfigs'][0]['natIP']} for instance in r.json()['items']
            }
        },
        "all": {
            "hosts": [instance['name'] for instance in r.json()['items']] 
        } 
    }
    return inventory

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'lh', ['list', 'host=', 'help'])
    except getopt.error, msg:
        print msg
        print "for help use --help"
        sys.exit(2)
    for o, a in opts:
        if o in ("-h", "--help"):
            print __doc__
            sys.exit(0)
        if o in ("-l", "--list"):
            print json.dumps(fetch_inventory())
        if o in ("--host"):
            print json.dumps(fetch_instance(a))

if __name__ == "__main__":
    main()