#!/usr/bin/python

import os, sys, requests, json, logging, uuid, time


#def get_uuids(services_array):
#  service_uuid = []
#  for service_item in services_array:
#    nsd_uuid=service_item['uuid']
#    service_uuid.append(nsd_uuid)    
#  return service_uuid


def create_json_NST(uuid):    
  nst_data = {}
  nst_data["name"] = "NST Integration Test"
  nst_data["version"] = "2.0"
  nst_data["author"] = "5GTango Developer"
  nst_data["vendor"] = "eu.5gTango"
  nst_data["nstNsdIds"] = []
  nsd_uuid = {}
  nsd_uuid["NsdId"] = uuid
  nst_data["nstNsdIds"].append(nsd_uuid)

  data=str(nst_data)
  return data
  

if __name__ == '__main__':
  NST = create_json_NST(sys.argv[1])
  NST = NST.replace('\'','"');
  sys.exit(NST)