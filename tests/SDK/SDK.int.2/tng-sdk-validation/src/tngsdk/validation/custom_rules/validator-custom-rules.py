import business_rules
from business_rules import run_all,export_rule_data
from business_rules.variables import *
from business_rules.actions import *
from business_rules.fields import *
from tngsdk.validation.util import read_descriptor_file
from tngsdk.validation import event
from tngsdk.validation.storage import DescriptorStorage

import datetime
import json
import os
import sys
import yaml
import logging

log = logging.getLogger(__name__)
evtlog = event.get_logger('validator.events')

# #TODO read this rules form an external YAML file 
# rules = [
# # vdu_resource_requirements_cpu_vcpus < 2
#     { 
#     "conditions": 
#     { "all":
#     [
#         { "name": "vdu_resource_requirements_cpu_vcpus",
#         "operator": "less_than",
#         "value": 6
#         }
#     ]
#     },
#     "actions": [
#         { "name": "raise_error",
#         "params": {"error_text": "The number of CPUs must be higher than 2!"},
#         }
#         ]
#     }
# ]


class Descriptor(object):
 
    def __init__(self,
                func
                # id,
                # vdu_resource_requirements_cpu_freq,
                # vdu_resource_requirements_cpu_vcpus,
                # vdu_resource_requirements_memory_size,
                # vdu_resource_connection_points_mng
                ):
        self.func = func
        # self.id=id               
        # self.vdu_resource_requirements_cpu_vcpus= vdu_resource_requirements_cpu_vcpus
        # self.vdu_resource_requirements_cpu_freq=vdu_resource_requirements_cpu_freq
        # self.vdu_resource_requirements_memory_size=vdu_resource_requirements_memory_size
        # self.vdu_resource_connection_points_mng=vdu_resource_connection_points_mng
        
        #TODO use VNFD file as input and populate all the variables
        print(dir(self.func))
        # print(self.func.content['virtual_deployment_units'][0]['vm_image_format'])
        # print(self.func.content['virtual_deployment_units'][0]['resource_requirements']['cpu']['vcpus'])
        # print(self.func.content['virtual_deployment_units'][0]['resource_requirements']['memory']['size'])
        # print(self.func.content['virtual_deployment_units'][0]['resource_requirements']['memory']['size_unit'])
        # print(self.func.content['virtual_deployment_units'][0]['resource_requirements']['storage']['size'])
        # print(self.func.content['virtual_deployment_units'][0]['resource_requirements']['storage']['size_unit'])
        # print(self.func.content['virtual_deployment_units'][0]['connection_points'][0]['id'])
        # print(type(self.func.content['virtual_deployment_units'][0]['connection_points'][0]['id']))


    def display_error(self, error_text):
        print("Error detected in custom rules: {}".format(error_text))
    
    def display_warning(self, warning_text):
        print("Warning detected in custom rules: {}".format(warning_text))

    
class DescriptorVariables(BaseVariables):

    def __init__(self, descriptor):
        self.func = descriptor.func

    # @numeric_rule_variable(label='Freq of vCPUs')
    # def Descriptorvdu_resource_requirements_cpu_freq(self):
    #     return (self.descriptor.vdu_resource_requirements_cpu_freq)

    # @string_rule_variable()
    # def current_month(self):
    #     return datetime.datetime.now().strftime("%B")

    @numeric_rule_variable(label='Size of RAM')
    def vdu_resource_requirements_ram_size(self):
        #return (self.descriptor.vdu_resource_requirements_memory_size)
        # TODO add checkings if proceed
        return self.func.content['virtual_deployment_units'][0]['resource_requirements']['memory']['size']

    @string_rule_variable(label='Unit of RAM')
    def vdu_resource_requirements_ram_size_unit(self):
        # TODO add checkings if proceed
        return str(self.func.content['virtual_deployment_units'][0]['resource_requirements']['memory']['size_unit'])

    @numeric_rule_variable(label='Number of vCPUs')
    def vdu_resource_requirements_cpu_vcpus(self):
        #return (self.descriptor.vdu_resource_requirements_cpu_vcpus)
        # TODO add checkings if proceed
        return self.func.content['virtual_deployment_units'][0]['resource_requirements']['cpu']['vcpus']

    @numeric_rule_variable(label='Size of storage')
    def vdu_resource_requirements_storage_size(self):
        # TODO add checkings if proceed
        return self.func.content['virtual_deployment_units'][0]['resource_requirements']['storage']['size']

    @string_rule_variable(label='Unit of storage')
    def vdu_resource_requirements_storage_size_unit(self):
        # TODO add checkings if proceed
        return str(self.func.content['virtual_deployment_units'][0]['resource_requirements']['storage']['size_unit']) 

    @string_rule_variable(label='Format of VM')
    def vdu_vm_resource_format(self):
        # TODO add checkings if proceed
        return str(self.func.content['virtual_deployment_units'][0]['vm_image_format']) 


    # @numeric_rule_variable(label='Number of mgmt points')
    # def vdu_resource_connection_points_mng(self):
    #     return (self.descriptor.vdu_resource_connection_points_mng)

class DescriptorActions(BaseActions):

    def __init__(self, descriptor):
        self.descriptor = descriptor

    # @rule_action(params={"sale_percentage": FIELD_NUMERIC})
    # def put_on_sale(self, sale_percentage):
    #     self.product.price = (1.0 - sale_percentage) * self.product.price
    #     self.product.save()

    # @rule_action(params={"number_to_order": FIELD_NUMERIC})
    # def order_more(self, number_to_order):
    #     self.product.order(number_to_order)
    @rule_action(params={"error_text": FIELD_TEXT})
    def raise_error(self, error_text):
        self.descriptor.display_error(error_text)

    @rule_action(params={"error_text": FIELD_TEXT})
    def raise_warning(self, error_text):
        self.descriptor.display_warning(error_text)

def process_rules(custom_rule_file, descriptor_file_name):
#def process_rules(custom_rule_file):

    # Read YAML rule file
    if not os.path.isfile(custom_rule_file):
        log.error("Invalid custom rule file")
        exit(1)
    
    try:
      fn_custom_rule=open(custom_rule_file, "r")
    except IOError:
      log.error("Error opening custom rule file: File does not appear to exist.")
      exit(1)

    try:
        rules=yaml.load(fn_custom_rule)
    except  (yaml.YAMLError, yaml.MarkedYAMLError) as e:
        log.error('The rule file seems to have contain invalid YAML syntax. Please fix and try again. Error: {}'.format(str(e)))
        exit(1)

    storage = DescriptorStorage()
    #descriptor_source = read_descriptor_file(descriptor_file_name)
    func = storage.create_function(descriptor_file_name)
    if not func:
        evtlog.log("Invalid function descriptor",
                "Couldn't store VNF of file '{0}'".format(descriptor_file_name),
                descriptor_file_name,
                'evt_function_invalid_descriptor')
        exit(1)


    # TODO populate descriptor from file
    #descriptor= Descriptor(func,"cona",1000,5,5,1)
    descriptor= Descriptor(func)

    variables= DescriptorVariables(descriptor)
    rule_to_export = export_rule_data(DescriptorVariables, DescriptorActions)

  #  print("DUMP OF RULES: \n"+json.dumps(rules))
    # Execute all the rules
    run_all(rule_list=rules,defined_variables=DescriptorVariables(descriptor),defined_actions=DescriptorActions(descriptor),stop_on_first_trigger=False)


if __name__ == "__main__":

    if len(sys.argv)!= 3:
    #if len(sys.argv)!= 2:
        log.error("This script takes exactly two arguments: example_descriptor <custom rule file> <descriptor file>")
        exit(1)

    custom_rule_file=sys.argv[1]
    descriptor_file_name=sys.argv[2]

    if not os.path.isfile(custom_rule_file):
        log.error("Invalid custom rule file")
        exit(1)
    
    if not os.path.isfile(descriptor_file_name):
         print("Invalid descriptor file")
         exit(1)

    process_rules(custom_rule_file,descriptor_file_name)
    #process_rules(custom_rule_file)





