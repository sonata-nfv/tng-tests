import re
import collections
import math
import os
import requests
import json
import yaml

class utility():
    dictionary = None
    def __init__(self): 
        self.dictionary = dict()
        
    def should_be_x_than (self, responseBody, relation, number2):
        print("responseBody length: ")
        print( len(responseBody))
        number1 = len(responseBody)
        if relation =="<":
            return float(number1) < float(number2)
        if relation ==">":
            return float(number1) > float(number2)
        if relation =="=>":
            return float(number1) >= float(number2)
        if relation =="<=":
            return float(number1) <= float(number2)
        if relation =="=":
            return float(number1) == float(number2)
        
    def set_to_dictionary(self, key, value):
        self.dictionary[key] = value 
    
    def upload_file(self, path, endpoint):
        filename = os.path.basename(path)
        f = open(path, 'rb')
        response = requests.post(url=endpoint, data =  {'package':filename},  files =  {'package':f})
        print(response.content) 
        return response.content
    def upload_descriptor_to_osm(self, path, data, bearer):
        bytes = open(data, 'rb').read()
        headers={'Authorization': bearer, 'Content-Type': 'application/octet-stream'}
        response = requests.post(url=path, data = {'name':'test'},files =  {'file':bytes}, verify=False, headers=headers)
        print('upload_descriptor_to_osm: ')
        print(response.content) 
        return response.content
    def auth_to_osm(self, data, endpoint):
        response = requests.post(url=endpoint, data =  data, verify = False )
        print(yaml.load(response.content)) 
        return yaml.load(response.content)
    def yaml_to_json(self, y):
        return yaml.load(y)
    def has_match(self, testResp, serviceResp):
        print('content: ')
        testResp = json.dumps(testResp)
        serviceResp = json.dumps(serviceResp)
        testResp = json.loads(testResp)
        serviceResp = json.loads(serviceResp)
        matches = []
        for td in testResp:
            for tag in td['testd'].get('testing_tags', []):
                for ns in serviceResp:
                    for t in ns['nsd'].get('testing_tags', []):
                        if t == tag and t not in matches:
                            matches.append(t)
        print('matches: ')        
        print(matches)
        if len(matches) > 0:
            return True
        else: 
            return False    
    def load_json(self, resp):
        loaded_json = json.dumps(resp)
        d = json.loads(loaded_json)
        array = []
        for x in d:
            array.append(x['uuid'])   
        return array    