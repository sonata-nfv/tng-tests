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
from unittest import mock
from tngsdk.validation.schema.validator import load_local_schema, load_remote_schema
from unittest.mock import patch


class UnitLoadSchemaTests(unittest.TestCase):

    @patch("tngsdk.validation.schema.validator.yaml")
    @patch("builtins.open")
    @patch("tngsdk.validation.schema.validator.os.path")
    def test_load_local_schema(self, m_os_path, m_open, m_yaml):
        # Ensure that a FileNotFoundError is raised
        # when the file does not exist
        m_os_path.isfile.return_value = False
        self.assertRaises(
            FileNotFoundError, load_local_schema, "/some/file/path")

        # Ensure a correct schema format and
        # a correct opening of the schema file
        m_os_path.isfile.return_value = True
        m_open.return_value = None
        m_yaml.load.return_value = "not a dict"
        self.assertRaises(
            AssertionError, load_local_schema, "/some/file/path")

        self.assertEqual(m_open.call_args,
                         mock.call('/some/file/path', 'r'))

        # Ensure that a dictionary is allowed to be returned
        sample_dict = {'dict_key': 'this is a dict'}
        m_os_path.isfile.return_value = True
        m_open.return_value = None
        m_yaml.load.return_value = sample_dict
        return_dict = load_local_schema("/some/file/path")
        self.assertEqual(sample_dict, return_dict)

    @patch("tngsdk.validation.schema.validator.yaml")
    @patch("tngsdk.validation.schema.validator.requests.get")
    def test_load_remote_schema(self, m_urlopen, m_yaml):

        sample_dict = {"key": "content"}
        m_yaml.load.return_value = sample_dict

        # Ensure that urlopen is accessing the same address of the argument
        load_remote_schema("url")
        self.assertEqual(m_urlopen.call_args, mock.call("url"))

        # Ensure it raises error on loading an invalid schema
        m_yaml.load.return_value = "not a dict"
        self.assertRaises(AssertionError, load_remote_schema, "url")

        # Ensure that a dictionary is allowed to be returned
        m_yaml.load.return_value = sample_dict
        return_dict = load_remote_schema("url")
        self.assertEqual(sample_dict, return_dict)
