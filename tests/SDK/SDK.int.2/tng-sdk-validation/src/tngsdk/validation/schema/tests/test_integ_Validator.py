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

import unittest
import pkg_resources
import os
from requests.exceptions import HTTPError, MissingSchema
from tngsdk.validation.schema.validator import load_local_schema, load_remote_schema


class IntLoadSchemaTests(unittest.TestCase):

    def test_load_invalid_local_template(self):
        """Test if the load schema is loading only available templates"""
        self.assertRaises(FileNotFoundError, load_local_schema, "test")

    def test_load_valid_local_schema(self):
        """ Test if the load schema is correctly loading the templates """
        # Access to local stored schemas for this test
        schema_f = pkg_resources.resource_filename(
            __name__, os.path.join("son-schema", 'pd-schema.yml'))

        schema = load_local_schema(schema_f)
        self.assertIsInstance(schema, dict)

        schema_f = pkg_resources.resource_filename(
            __name__, os.path.join("son-schema", 'nsd-schema.yml'))

        schema = load_local_schema(schema_f)
        self.assertIsInstance(schema, dict)

        schema_f = pkg_resources.resource_filename(
            __name__, os.path.join("son-schema", 'vnfd-schema.yml'))

        schema = load_local_schema(schema_f)
        self.assertIsInstance(schema, dict)

    def test_load_invalid_remote_template_unavailable(self):
        """
        Test if it raises a HTTP error with a valid
        but unavailable schema URL.
        """
        self.assertRaises(HTTPError,
                          load_remote_schema,
                          "https://raw.githubusercontent.com/sonata-nfv/"
                          "son-schema/v30/function-descriptor/vnfd-schema.yml")

    def test_load_invalid_remote_template_invalid(self):
        """
        Test if it raises an error with an invalid
        schema URL.
        """
        self.assertRaises(MissingSchema,
                          load_remote_schema,
                          "some.incorrect/..url")

    def test_load_valid_remote_schema(self):
        """
        Test if the load_remote_schema is
        retrieving and loading the templates correctly.
        """
        schema = load_remote_schema(
            "https://raw.githubusercontent.com/"
            "sonata-nfv/son-schema/master/package-descriptor/pd-schema.yml")
        self.assertIsInstance(schema, dict)
