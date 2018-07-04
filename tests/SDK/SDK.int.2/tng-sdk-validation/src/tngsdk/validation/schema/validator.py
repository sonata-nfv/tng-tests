#  Copyright (c) 2015 SONATA-NFV, UBIWHERE
# ALL RIGHTS RESERVED.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Neither the name of the SONATA-NFV, UBIWHERE
# nor the names of its contributors may be used to endorse or promote
# products derived from this software without specific prior written
# permission.
#
# This work has been performed in the framework of the SONATA project,
# funded by the European Commission under Grant number 671517 through
# the Horizon 2020 and 5G-PPP programmes. The authors would like to
# acknowledge the contributions of their colleagues of the SONATA
# partner consortium (www.sonata-nfv.eu).

import logging
import coloredlogs
import validators
import os
import yaml
import jsonschema
import requests
from requests.exceptions import RequestException

from jsonschema import SchemaError
from jsonschema import ValidationError

log = logging.getLogger(__name__)


class SchemaValidator(object):

    # ID of schema templates
    SCHEMA_PACKAGE_DESCRIPTOR = 'PD'
    SCHEMA_SERVICE_DESCRIPTOR = 'NSD'
    SCHEMA_FUNCTION_DESCRIPTOR = 'VNFD'

    def __init__(self, workspace, preload=False):
        # Assign parameters
        coloredlogs.install(level=workspace.log_level)
        self._workspace = workspace
        self._schemas_local_master = workspace.schemas_local_master
        self._schemas_remote_master = 'https://raw.githubusercontent.com/sonata-nfv/tng-schema/master'

        self._schemas = {}

        # Configure location for schemas
        self.config_schema_locations()

        # Keep a library of loaded schemas to avoid re-loading
        self._schemas_library = dict()

        self._error_msg = ''

        # if preload, load local cached schema files
        if preload:
            self.preload_local_schemas()

    def config_schema_locations(self):
        self._schemas = {
            self.SCHEMA_PACKAGE_DESCRIPTOR: {
                'local': os.path.join(self._schemas_local_master,
                                      'package-specification/napd-schema.yml'),
                'remote': self._schemas_remote_master +
                '/package-specification/napd-schema.yml'
            },
            self.SCHEMA_SERVICE_DESCRIPTOR: {
                'local': os.path.join(self._schemas_local_master,
                                      'service-descriptor/nsd-schema.yml'),
                'remote': self._schemas_remote_master +
                '/service-descriptor/nsd-schema.yml'
            },
            self.SCHEMA_FUNCTION_DESCRIPTOR: {
                'local': os.path.join(self._schemas_local_master,
                                      'function-descriptor/vnfd-schema.yml'),
                'remote': self._schemas_remote_master +
                '/function-descriptor/vnfd-schema.yml'
            }
        }

    @property
    def error_msg(self):
        return self._error_msg

    @error_msg.setter
    def error_msg(self, value):
        self._error_msg = value

    def get_remote_schema(self, descriptor):
        """
        Obtains current remote schema URL for a
        particular descriptor.

        :param descriptor: the target descriptor
        :return: the schema URL
        """
        return self._schemas[descriptor]['remote']

    def get_local_schema(self, descriptor):
        """
        Obtains current local schema file for a
        particular descriptor

        :param descriptor: the target descriptor
        :return: the schema filename
        """
        return self._schemas[descriptor]['local']

    def preload_local_schemas(self):
        """
        Pre-loads local available schemas to _schemas_library,
        avoiding to request them later from remote locations.
        When this is invoked upon object creation, the local schema cache files
        should be erased when remote object reloading is necessary.
        """
        schemas = [self.SCHEMA_PACKAGE_DESCRIPTOR,
                   self.SCHEMA_SERVICE_DESCRIPTOR,
                   self.SCHEMA_FUNCTION_DESCRIPTOR]

        for schema in schemas:
            schema_file = self._schemas[schema]['local']
            if not os.path.isfile(schema_file):
                continue
            try:
                self._schemas_library[schema] = load_local_schema(schema_file)
            except FileNotFoundError:
                continue

    def load_schema(self, template, reload=False):
        """
        Load schema from a local file or a remote URL.
        If the same schema was previously loaded
        and reload=False it will return the schema
        stored in cache. If reload=True it will force
        the reload of the schema.

        :param template: Name of local file or URL to remote schema
        :param reload: Force the reload, even if it was previously loaded
        :return: The loaded schema as a dictionary
        """
        # Check if template is already loaded and present in _schemas_library
        if template in self._schemas_library and not reload:
            log.debug("Loading previously stored schema for {}"
                      .format(template))

            return self._schemas_library[template]

        # Load Online Schema
        schema_addr = self._schemas[template]['remote']
        if validators.url(schema_addr):
            try:
                log.debug("Loading schema '{}' from remote location '{}'"
                          .format(template, schema_addr))

                # Load schema from remote source
                self._schemas_library[template] = \
                    load_remote_schema(schema_addr)

                # Update the corresponding local schema file
                write_local_schema(self._schemas_local_master,
                                   self._schemas[template]['local'],
                                   self._schemas_library[template])

                return self._schemas_library[template]

            except RequestException as e:
                log.warning("Could not load schema '{}' from remote "
                            "location '{}', error: {}"
                            .format(template, schema_addr, e))
        else:
            log.warning("Invalid schema URL '{}'".format(schema_addr))

        # Load Offline Schema
        schema_addr = self._schemas[template]['local']
        if os.path.isfile(schema_addr):
            try:
                log.debug("Loading schema '{}' from local file '{}'"
                          .format(template, schema_addr))

                self._schemas_library[template] = \
                    load_local_schema(schema_addr)

                return self._schemas_library[template]

            except FileNotFoundError:
                log.warning("Could not load schema '{}' from local file '{}'"
                            .format(template, schema_addr))

        else:
            log.warning("Schema file '{}' not found.".format(schema_addr))

        log.error("Failed to load schema '{}'".format(template))

    def validate(self, descriptor, schema_id):
        """
        Validate a descriptor against a schema template
        :param descriptor:
        :param schema_id:
        :return:
        """
        try:
            jsonschema.validate(descriptor, self.load_schema(schema_id))
            return True

        except ValidationError as e:
            log.error("Failed to validate Descriptor against schema '{}'"
                      .format(schema_id))
            self.error_msg = e.message
            log.error(e.message)
            return

        except SchemaError as e:
            log.error("Invalid Schema '{}'".format(schema_id))
            self.error_msg = e.message
            log.debug(e)
            return

    def get_descriptor_type(self, descriptor):
        """
        This function obtains the type of a descriptor.
        Its methodology is based on trial-error, since it
        attempts to validate the descriptor against the
        available schema templates until a success is achieved
        """
        # Gather schema templates ids
        templates = {self.SCHEMA_PACKAGE_DESCRIPTOR,
                     self.SCHEMA_SERVICE_DESCRIPTOR,
                     self.SCHEMA_FUNCTION_DESCRIPTOR}

        # Cycle through templates until a success validation is return
        for schema_id in templates:
            try:
                jsonschema.validate(descriptor, self.load_schema(schema_id))
                return schema_id

            except ValidationError:

                continue

            except SchemaError as error_detail:
                log.error("Invalid Schema '{}'".format(schema_id))
                log.debug(error_detail)
                return


def write_local_schema(schemas_root, filename, schema):
    """
    Writes a schema to a local file.
    :param schemas_root: The location of schema descriptor
    :param filename: The name of the schema file to be written.
    :param schema: The schema content as a dictionary.
    :return:
    """
    # Verify if local dir structure already exists! If not, create it.
    if not os.path.isdir(schemas_root):
        log.debug("Schema directory '{}' not found. Creating it."
                  .format(schemas_root))
        print("Schema directory '{}' not found. Creating it."
                  .format(schemas_root))

        os.mkdir(schemas_root)
    else:
        print("Schema directory '{}' found. We do not need to create it."
                  .format(schemas_root))     

    if os.path.isfile(filename):
        log.debug("Replacing schema file '{}'".format(filename))
        print("Replacing schema file '{}'".format(filename))
    else:
        log.debug("Writing schema file '{}'".format(filename))
        print("Writing schema file '{}'".format(filename))

    if not os.path.exists(os.path.dirname(filename)):
        log.debug("Schema directory '{}' not found. Creating it."
                  .format(schemas_root))
        try:
            os.makedirs(os.path.dirname(filename))
        except OSError as exc: # Guard against race condition
            if exc.errno != errno.EEXIST:
                raise 

    schema_f = open(filename, 'w')
    yaml.dump(schema, schema_f)
    schema_f.close()


def load_local_schema(filename):
    """
    Search for a given template on the schemas folder
    inside the current package.

    :param filename: The name of the schema file to look for
    :return: The loaded schema as a dictionary
    """
    # Confirm that schema file exists
    if not os.path.isfile(filename):
        log.warning("Schema file '{}' does not exist.".format(filename))
        raise FileNotFoundError

    # Read schema file and return the schema as a dictionary
    schema_f = open(filename, 'r')
    schema = yaml.load(schema_f)
    assert isinstance(schema, dict), "Failed to load schema file '{}'. " \
                                     "Not a dictionary.".format(filename)

    return schema


def load_remote_schema(template_url):
    """
    Retrieve a remote schema from the provided URL
    :param template_url: The URL of the required schema
    :return: The loaded schema as a dictionary
    """
    response = requests.get(template_url)
    response.raise_for_status()
    tf = response.text
    schema = yaml.load(tf)
    assert isinstance(schema, dict)
    return schema
