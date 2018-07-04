#!/usr/bin/python

import os, sys, requests, json, logging, uuid, time
from datetime import datetime

service_uuid = []  #List of services uuid to create the NST

#STEP 1: Get a list of available services
url = "http://pre-int-sp-ath.5gtango.eu:32002/api/v3/services"
response = requests.get(url)


#STEP 2: Save the UUID of the NSDs to be included in the NST
if (response.status_code == 200):
  print("Services information request went fine with code: " + str(response.status_code))
  logging.info("Services information request went fine with code: " + str(response.status_code))
  services_array = json.loads(response.text)
  for service_item in services_array:
    nsd_uuid=service_item['uuid']
    service_uuid.append(nsd_uuid)                                              #Adds the dictionary element into the list
else:
  error = "ERROR GET SERVICES: " +str(response.status_code)+ "message: " +str(response.json())
  print(error)
  logging.info(error)


#STEP 3: Build the NST composed by a list of NSD UUIDs
nst_data = {}
nst_data["name"] = "NET Integration Test"
nst_data["version"] = "1.3"
nst_data["author"] = "5GTango Developer"
nst_data["vendor"] = "5GTango Vendor"
nst_data["nstNsdIds"] = []
for uuid_item in service_uuid:
  nsd_uuid = {}
  nsd_uuid["NsdId"] = str(uuid_item)
  nst_data["nstNsdIds"].append(nsd_uuid)

#STEP 4: Save the returned NST UUID
url = "http://pre-int-sp-ath.5gtango.eu:5998/api/nst/v1/descriptors"
content_header = {'Content-Type':'application/json'}
nst_data_json = json.dumps(nst_data)
response = requests.post(url, data=nst_data_json, headers=content_header)
if (response.status_code == 201):
  NST_jsonresponse = json.loads(response.text)
  logging.info('NetSlice Template created with code : ' + str(response.status_code))
  logging.info('NetSlice Template content: ' + str(response.text))
else:
  error = "ERROR POST NST: " +str(response.status_code)+ "message: " +str(response.json())
  print(error)
  logging.info(error)


#STEP5: Check that the NST is stored in the Catalogue by querying
uuid_nst = str(NST_jsonresponse["uuid"])
url = "http://pre-int-sp-ath.5gtango.eu:5998/api/nst/v1/descriptors/" + uuid_nst
content_header = {'Content-Type':'application/json', 'Accept':'application/json'}
response = requests.get(url, headers=content_header)
if (response.status_code == 200):
  logging.info('NST coming from catalogues: ' + str(response.text))
else:
  error = "ERROR GET NST: " +str(response.status_code)+ "message: " +str(response.json())
  print(error)
  logging.info(error)


#STEP 6: Delete the NST
response = requests.delete(url)                                                 #Reusing the previous url
if (response.status_code == 204):
  print(response.status_code)
  logging.info('NST was deleted.')
else:
  error = "ERROR DELETE NST: " +str(response.status_code)+ "message: " +str(response.json())
  print(error)
  logging.info(error)