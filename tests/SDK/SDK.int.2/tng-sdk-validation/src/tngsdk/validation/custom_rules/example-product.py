import business_rules
from business_rules import run_all,export_rule_data
from business_rules.variables import *
from business_rules.actions import *
from business_rules.fields import *
import datetime
import json

class Product(object):
 
    def __init__(self,id,current_inventory,last_order,price):
        self.id=id
        self.current_inventory=current_inventory
        self.last_order=last_order
        self.price=price
    
    def save(self):
        print("Product save(). Price: {}".format(self.price))

    def order(self, number):
        print("Product order({})".format(number))


    
class ProductVariables(BaseVariables):

    def __init__(self, product):
        self.product = product

    @numeric_rule_variable
    def current_inventory(self):
        return self.product.current_inventory

    @numeric_rule_variable(label='Days until expiration')
    def expiration_days(self):
        return (self.product.last_order - datetime.date.today()).days

    @string_rule_variable()
    def current_month(self):
        return datetime.datetime.now().strftime("%B")



class ProductActions(BaseActions):

    def __init__(self, product):
        self.product = product

    @rule_action(params={"sale_percentage": FIELD_NUMERIC})
    def put_on_sale(self, sale_percentage):
        self.product.price = (1.0 - sale_percentage) * self.product.price
        self.product.save()

    @rule_action(params={"number_to_order": FIELD_NUMERIC})
    def order_more(self, number_to_order):
        self.product.order(number_to_order)



producto= Product("cona",34,datetime.date(2018, 6, 26),100)
variables= ProductVariables(producto)

rules = [
# expiration_days < 5 AND current_inventory > 20
    { "conditions": 
    { "all":
    [
        { "name": "expiration_days",
        "operator": "less_than",
        "value": 5,
        },
        { "name": "current_inventory",
        "operator": "greater_than",
        "value": 20,
        },
    ]
    },
    "actions": [
        { "name": "put_on_sale",
        "params": {"sale_percentage": 0.025},
        },
        ]
    },

   {
	"conditions": {
		"any": [{
			"name": "current_inventory",
			"operator": "less_than",
			"value": 5
		}],
		"all": [{
			"name": "current_month",
			"operator": "equal_to",
			"value": "December"
		}, {
			"name": "current_inventory",
			"operator": "less_than",
			"value": 20
		}]
	},
	"actions": [{
		"name": "order_more",
		"params": {
			"number_to_order": 40
		}
	}]
}
]

rule_to_export = export_rule_data(ProductVariables, ProductActions)
print("DUMP OF RULES: \n"+json.dumps(rules))
run_all(rule_list=rules,defined_variables=ProductVariables(producto),defined_actions=ProductActions(producto),stop_on_first_trigger=True)



