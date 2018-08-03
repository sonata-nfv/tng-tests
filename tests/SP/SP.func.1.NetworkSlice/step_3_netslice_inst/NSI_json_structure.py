#!/usr/bin/python

import os, sys, requests, json, logging, uuid, time


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
