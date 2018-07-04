import business_rules
from business_rules import run_all,export_rule_data
from business_rules.variables import *
from business_rules.actions import *
from business_rules.fields import *
import datetime
import json
import os
import sys
import yaml

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
                id,
                vdu_resource_requirements_cpu_freq,
                vdu_resource_requirements_cpu_vcpus,
                vdu_resource_requirements_memory_size,
                vdu_resource_connection_points_mng
                ):

        self.id=id               
        self.vdu_resource_requirements_cpu_vcpus= vdu_resource_requirements_cpu_vcpus
        self.vdu_resource_requirements_cpu_freq=vdu_resource_requirements_cpu_freq
        self.vdu_resource_requirements_memory_size=vdu_resource_requirements_memory_size
        self.vdu_resource_connection_points_mng=vdu_resource_connection_points_mng
        #TODO use VNFD file as input and populate all the variables
    
    def cpu_requirements(self):
        print("CPU requeriments. Number of CPUS: {} Freq of CPUs: {}".format(self.vdu_resource_requirements_cpu_vcpus,  self.vdu_resource_requirements_cpu_freq))

    def ram_requirements(self):
        print("RAM requeriments. Amount of RAM: {}".format(self.vdu_resource_requirements_memory_size))

    def display_error(self, error_text):
        print("Error detected in custom rules: {}".format(error_text))

    
class DescriptorVariables(BaseVariables):

    def __init__(self, descriptor):
        self.descriptor = descriptor

    @numeric_rule_variable(label='Freq of vCPUs')
    def Descriptorvdu_resource_requirements_cpu_freq(self):
        return (self.descriptor.vdu_resource_requirements_cpu_freq)

    # @string_rule_variable()
    # def current_month(self):
    #     return datetime.datetime.now().strftime("%B")

    @numeric_rule_variable(label='Number of vCPUs')
    def vdu_resource_requirements_cpu_vcpus(self):
        return (self.descriptor.vdu_resource_requirements_cpu_vcpus)

    @numeric_rule_variable(label='Amount of RAM')
    def vdu_resource_requirements_cpu_vcpus(self):
        return (self.descriptor.vdu_resource_requirements_memory_size)

    @numeric_rule_variable(label='Number of mgmt points')
    def vdu_resource_connection_points_mng(self):
        return (self.descriptor.vdu_resource_connection_points_mng)

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


#def process_rules(custom_rule_file, descriptor_file):
def process_rules(custom_rule_file):

    # Read YAML rule file
    if not os.path.isfile(custom_rule_file):
        print("Invalid custom rule file")
        exit(1)
    
    try:
      fn_custom_rule=open(custom_rule_file, "r")
    except IOError:
      print "Error: File does not appear to exist."
      exit(1)
    
    rules=yaml.load(fn_custom_rule)
    # rules='['+json.dumps(rules)+']'
    print(type(rules))
    print(dir(rules))
    print(rules)
    #print('['+json.dumps(rules)+']')
    # print(rules_yaml)
    # rules_json = json.dumps('{}')
    # rules=json.dumps(rules_yaml, rules_json, indent=0)

    # TODO populate descriptor from file
    descriptor= Descriptor("cona",1000,5,5,1)

    variables= DescriptorVariables(descriptor)
    rule_to_export = export_rule_data(DescriptorVariables, DescriptorActions)

  #  print("DUMP OF RULES: \n"+json.dumps(rules))
    # Execute all the rules
    run_all(rule_list=rules,defined_variables=DescriptorVariables(descriptor),defined_actions=DescriptorActions(descriptor),stop_on_first_trigger=True)


if __name__ == "__main__":

    # if len(sys.argv)!= 3:
    if len(sys.argv)!= 2:
        print("This script takes exactly two arguments: example_descriptor <custom rule file> <descriptor file>")
        exit(1)

    custom_rule_file=sys.argv[1]
    # descriptor_file=sys.argv[2]

    if not os.path.isfile(custom_rule_file):
        print("Invalid custom rule file")
        exit(1)
    
    # if not os.path.isfile(descriptor_file):
    #     print("Invalid descriptor file")
    #     exit(1)

    #process_rules(custom_rule_file,descriptor_file)
    process_rules(custom_rule_file)





