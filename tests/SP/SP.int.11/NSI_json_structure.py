#!/usr/bin/python

import os, sys, requests, json, logging, uuid, time


#def get_uuids(services_array):
#  service_uuid = []
#  for service_item in services_array:
#    nsd_uuid=service_item['uuid']
#    service_uuid.append(nsd_uuid)    
#  return service_uuid


#{"nstId": "26c540a8-1e70-4242-beef-5e77dfa05a41"}

def create_json_NSI(uuid):    
  nsi_data = {}
  nsi_data["name"] = "NSI_Example"
  nsi_data["description"] = "NSI_Integration_Test_Example"
  nsi_data["nstId"] = uuid
  data=str(nsi_data)
  return data
  

if __name__ == '__main__':
  print("argument numero 1: " + str(sys.argv[1]))
  NSI = create_json_NSI(sys.argv[1])
  NSI = NSI.replace('\'','"');
  sys.exit(NSI)
