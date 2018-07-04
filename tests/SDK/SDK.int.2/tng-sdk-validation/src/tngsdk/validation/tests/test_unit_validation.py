#  Copyright (c) 2015 SONATA-NFV, 5GTANGO, UBIWHERE, QUOBIS SL.
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
# Neither the name of the SONATA-NFV, 5GTANGO, UBIWHERE, QUOBIS SL.
# nor the names of its contributors may be used to endorse or promote
# products derived from this software without specific prior written
# permission.
#
# This work has been performed in the framework of the SONATA project,
# funded by the European Commission under Grant number 671517 through
# the Horizon 2020 and 5G-PPP programmes. The authors would like to
# acknowledge the contributions of their colleagues of the SONATA
# partner consortium (www.sonata-nfv.eu).
#
# This work has also been performed in the framework of the 5GTANGO project,
# funded by the European Commission under Grant number 761493 through
# the Horizon 2020 and 5G-PPP programmes. The authors would like to
# acknowledge the contributions of their colleagues of the SONATA
# partner consortium (www.5gtango.eu).

import unittest
import os
from tngsdk.validation.cli import parse_args
from tngsdk.validation.validator import Validator


SAMPLES_DIR = os.path.join('src','tngsdk','validation','tests','samples')

class TngSdkValidationTest(unittest.TestCase):

    def test_validate_function_valid(self):
        """
        Tests the validation of a valid 5GTANGO function.
        """
        functions_path = os.path.join(SAMPLES_DIR, 'functions', 'valid-son')
        validator = Validator()
        validator.configure(syntax=True, integrity=True, topology=True)
        validator.validate_function(functions_path)

        self.assertEqual(validator.error_count, 0)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_service_topology_valid(self):
        """
        Tests the correct validation of a service topology
        """
        service_path = os.path.join(SAMPLES_DIR, 'services', 'valid-son', 'valid.yml')
        functions_path = os.path.join(SAMPLES_DIR, 'functions', 'valid-son')

        validator = Validator()
        validator.configure(syntax=True, integrity=True, topology=True, dpath = functions_path)
        validator.validate_service(service_path)

        self.assertEqual(validator.error_count, 0)
        self.assertEqual(validator.warning_count, 0)

    # def test_validate_service_topology_invalid(self):
    #     """
    #     Tests the incorrect validation of a service topology
    #     """
    #     service_path = os.path.join(SAMPLES_DIR, 'services', 'invalid_topology.yml')
    #     functions_path = os.path.join(SAMPLES_DIR, 'functions', 'valid-son')
    #
    #     validator = Validator()
    #     validator.configure(syntax=True, integrity=True, topology=True, dpath = functions_path)
    #     validator.validate_service(service_path)
    #
    #     self.assertEqual(validator.error_count, 0)
    #     self.assertEqual(validator.warning_count, 0)

    def test_validate_function_topology_invalid(self):
        """
        Tests the incorrect validation of a function topology
        """
        functions_path = os.path.join(SAMPLES_DIR, 'functions', 'invalid_topology-son')

        validator = Validator()
        validator.configure(syntax=True, integrity=True, topology=True)
        validator.validate_function(functions_path)

        self.assertEqual(validator.error_count, 1)
        self.assertEqual(validator.warning_count, 1)

    def test_validate_function_topology_valid(self):
        """
        Tests the correct validation of a function topology
        """
        functions_path = os.path.join(SAMPLES_DIR, 'functions', 'valid-son')

        validator = Validator()
        validator.configure(syntax=True, integrity=True, topology=True)
        validator.validate_function(functions_path)

        self.assertEqual(validator.error_count, 0)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_service_integrity_valid(self):
        """
        Tests the correct validation of a service integrity
        """
        service_path = os.path.join(SAMPLES_DIR, 'services', 'valid-son', 'valid.yml')
        functions_path = os.path.join(SAMPLES_DIR, 'functions', 'valid-son')

        validator = Validator()
        validator.configure(syntax=True, integrity=True, topology=False, dpath = functions_path)
        validator.validate_service(service_path)

        self.assertEqual(validator.error_count, 0)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_service_integrity_invalid(self):
        """
        Tests the incorrect validation of a service integrity
        """
        service_path = os.path.join(SAMPLES_DIR, 'services', 'valid-son', 'valid.yml')
        functions_path = os.path.join(SAMPLES_DIR, 'functions', 'invalid_integrity-son')

        validator = Validator()
        validator.configure(syntax=True, integrity=True, topology=False, dpath = functions_path)
        validator.validate_service(service_path)

        self.assertEqual(validator.error_count, 3)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_function_integrity_valid(self):
        """
        Tests the correct validation of a function integrity.
        """
        functions_path = os .path.join(SAMPLES_DIR, 'functions', 'valid-son')
        validator = Validator()
        validator.configure(syntax=True, integrity=True, topology=False)
        validator.validate_function(functions_path)

        self.assertEqual(validator.error_count, 0)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_function_integrity_invalid(self):
        """
        Tests the incorrect validation of a function integrity.
        """
        functions_path = os .path.join(SAMPLES_DIR, 'functions', 'invalid_integrity-son')
        validator = Validator()
        validator.configure(syntax=True, integrity=True, topology=False)
        validator.validate_function(functions_path)

        self.assertEqual(validator.error_count, 3)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_service_syntax_valid(self):
        """
        Tests the correct validation of a service syntax
        """
        service_path = os.path.join(SAMPLES_DIR, 'services', 'valid-son', 'valid.yml')

        validator = Validator()
        validator.configure(syntax=True, integrity=False, topology=False)
        validator.validate_service(service_path)

        self.assertEqual(validator.error_count, 0)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_service_syntax_valid_simplest_nsd(self):
        """
        Tests the correct validation of a service syntax simplest nsd
        """
        service_path = os.path.join(SAMPLES_DIR, 'services', 'valid-syntax-tng', 'simplest-example.yml')

        validator = Validator()
        validator.configure(syntax=True, integrity=False, topology=False)
        validator.validate_service(service_path)

        self.assertEqual(validator.error_count, 0)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_service_syntax_invalid_unexpected_field(self):
        """
        Tests the incorrect validation of a service syntax with a unexpected field in the nsd
        """
        service_path = os.path.join(SAMPLES_DIR, 'services', 'invalid-syntax-tng', 'unexpected_field.yml')

        validator = Validator()
        validator.configure(syntax=True, integrity=False, topology=False)
        validator.validate_service(service_path)

        self.assertEqual(validator.error_count, 1)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_service_syntax_invalid_required_properties(self):
        """
        Tests the incorrect validation of a service syntax with required field in the nsd
        """
        service_path = os.path.join(SAMPLES_DIR, 'services', 'invalid-syntax-tng', 'required_properties.yml')

        validator = Validator()
        validator.configure(syntax=True, integrity=False, topology=False)
        validator.validate_service(service_path)

        self.assertEqual(validator.error_count, 1)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_function_syntax_valid(self):
        """
        Tests the syntax validation of a valid 5GTANGO function.
        """
        functions_path = os.path.join(SAMPLES_DIR, 'functions', 'valid-syntax-tng')
        validator = Validator()
        validator.configure(syntax=True, integrity=False, topology=False)
        validator.validate_function(functions_path)

        self.assertEqual(validator.error_count, 0)
        self.assertEqual(validator.warning_count, 0)

    def test_validate_function_syntax_invalid(self):
        """
        Tests the syntax validation of a valid 5GTANGO function.
        """
        functions_path = os.path.join(SAMPLES_DIR, 'functions', 'invalid-syntax-tng')
        validator = Validator()
        validator.configure(syntax=True, integrity=False, topology=False)
        validator.validate_function(functions_path)

        self.assertEqual(validator.error_count, 5)
        self.assertEqual(validator.warning_count, 0)



if __name__ == "__main__":
    unittest.main()
