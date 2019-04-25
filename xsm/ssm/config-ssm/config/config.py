"""
Copyright (c) 2015 SONATA-NFV, 2017 5GTANGO
ALL RIGHTS RESERVED.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Neither the name of the SONATA-NFV, 5GTANGO
nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written
permission.

This work has been performed in the framework of the SONATA project,
funded by the European Commission under Grant number 671517 through
the Horizon 2020 and 5G-PPP programmes. The authors would like to
acknowledge the contributions of their colleagues of the SONATA
partner consortium (www.sonata-nfv.eu).

This work has been performed in the framework of the 5GTANGO project,
funded by the European Commission under Grant number 761493 through
the Horizon 2020 and 5G-PPP programmes. The authors would like to
acknowledge the contributions of their colleagues of the 5GTANGO
partner consortium (www.5gtango.eu).
"""

import logging
import yaml
import tnglib
from smbase.smbase import smbase

logging.basicConfig(level=logging.INFO)
LOG = logging.getLogger("ssm-config")
LOG.setLevel(logging.DEBUG)
logging.getLogger("son-mano-base:messaging").setLevel(logging.INFO)


class configSSM(smbase):

    def __init__(self, connect_to_broker=True):

        """
        :param specific_manager_type: specifies the type of specific manager
        that could be either fsm or ssm.
        :param service_name: the name of the service that this specific manager
        belongs to.
        :param function_name: the name of the function that this specific
        manager belongs to, will be null in SSM case
        :param specific_manager_name: the actual name of specific manager
        (e.g., scaling, placement)
        :param id_number: the specific manager id number which is used to
        distinguish between multiple SSM/FSM that are created for the same
        objective (e.g., scaling with algorithm 1 and 2)
        :param version: version
        :param description: description
        """

        self.sm_id = "config"
        self.sm_version = "0.1"

        super(self.__class__, self).__init__(sm_id=self.sm_id,
                                             sm_version=self.sm_version,
                                             connect_to_broker=connect_to_broker)

    def on_registration_ok(self):

        # The ssm registration was successful
        LOG.debug("Received registration ok event.")

        # send the status to the SMR
        status = 'Subscribed, waiting for alert message'
        message = {'name': self.sm_id,
                   'status': status}
        self.manoconn.publish(topic='specific.manager.registry.ssm.status',
                              message=yaml.dump(message))

        # Subscribing to the topics that the ssm needs to listen on
        topic = "generic.ssm." + str(self.sfuuid)
        self.manoconn.subscribe(self.message_received, topic)
        LOG.info("Subscribed to " + topic + " topic.")

    def message_received(self, ch, method, props, payload):
        """
        This method handles received messages
        """

        # Decode the content of the message
        request = yaml.load(payload)

        # Don't trigger on non-request messages
        if "ssm_type" not in request.keys():
            LOG.info("Received a non-request message, ignoring...")
            return

        # Create the response
        response = None

        # the 'ssm_type' field in the content indicates for which type of
        # ssm this message is intended.
        if str(request["ssm_type"]) == "placement":
            LOG.info("Placement event received: " + str(request["content"]))
            response = self.placement_event(request["content"])

        if str(request["ssm_type"]) == "task":
            LOG.info("Task event received: " + str(request))
            response = self.task_event(request)

        if str(request["ssm_type"]) == "configure":
            LOG.info("Config event received: " + str(request))
            response = self.configure_event(request)

        # If a response message was generated, send it back to the FLM
        LOG.info("Response to request generated:" + str(response))
        topic = "generic.ssm." + str(self.sfuuid)
        corr_id = props.correlation_id
        self.manoconn.notify(topic,
                             yaml.dump(response),
                             correlation_id=corr_id)
        return

    def placement_event(self, content):
        """
        This method handles a placement event.
        """

        # Dummy content
        response = {'status': 'completed'}
        return response

    def task_event(self, content):
        """
        This method handles a task event.
        """

        # Update the received schedule
        schedule = content['schedule']

        schedule.insert(9, 'vnfs_config')
        schedule.insert(9, 'configure_ssm')

        response = {'schedule': schedule, 'status': 'COMPLETED'}

        LOG.info("task request responded to: " + str(response))

        return response

    def configure_event(self, content):
        """
        This method handles a configure event.
        """

        # This configure event will generate the message that the
        # fsms should write to their VM.
        ips = {}

        for vnf in content['functions']:
            vnfr = vnf['vnfr']
            ips[vnfr['name']] = tnglib.get_ips_from_vnfr(vnfr)[1]

        response = {}
        response['vnf'] = []

        for vnf in content['functions']:
            new_entry = {}
            new_entry['id'] = vnf['id']
            new_entry['configure'] = {'trigger': True,
                                      'payload': {'message': ips}}

            response['vnf'].append(new_entry)

        LOG.info("Generated response: " + str(response))

        return response

def main():
    configSSM()

if __name__ == '__main__':
    main()
