#  Copyright (c) 2015 SONATA-NFV, 5GTANGO, UBIWHERE, Paderborn University
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
# Neither the name of the SONATA-NFV, 5GTANGO, UBIWHERE, Paderborn University
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
import tempfile
import shutil
from tngsdk.validation import cli
from tngsdk.validation.validator import Validator

SAMPLE_DIR='src/tngsdk/validation/tests/'

class TngSdkValidationCliTest(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_cli_validation(self):
        # args = cli.parse_args(
        #     ["-u", "misc/5gtango-ns-package-example.tgo",
        #      "-o", tempdir])
        # r = cli.dispatch(args)
        # self.assertIsNone(r.error)
        # shutil.rmtree(tempdir)
        # TODO
        pass

    def test_cli_validation_invalid(self):
        # tempdir = tempfile.mkdtemp()
        # args = cli.parse_args(
        #     ["-u", "misc/5gtango-ns-package-example-malformed.tgo",
        #      "-o", tempdir])
        # r = cli.dispatch(args)
        # self.assertIsNotNone(r.error)
        # shutil.rmtree(tempdir)
        # TODO
        pass

    def test_cli_validation_function_syntax_ok(self):
        validator = Validator()
        input_args=['--syntax', '--function', SAMPLE_DIR+'samples/functions/valid-syntax-tng/tcpdump-vnfd-tng.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_function_syntax_ko_aditional_properties(self):
        validator = Validator()
        input_args=['--syntax', '--function', SAMPLE_DIR+'samples/functions/invalid-syntax-tng/invalid-default-vnfd-tng.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 1)

    def test_cli_validation_function_syntax_ko_bad_syntax(self):
        validator = Validator()
        input_args=['--syntax', '--function', SAMPLE_DIR+'samples/functions/invalid-syntax-tng/invalid-firewall-vnfd-tng.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 1)

    def test_cli_validation_function_syntax_ko_dext(self):
        validator = Validator()
        input_args=['--syntax', '--function', SAMPLE_DIR+'samples/functions/invalid-syntax-tng/', '--dext', 'yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 5)

    def test_cli_validation_function_syntax_ok_dext(self):
        validator = Validator()
        input_args=['--syntax', '--function', SAMPLE_DIR+'samples/functions/valid-syntax-tng/', '--dext', 'yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_service_syntax_ok_simplest_nsd(self):
        validator = Validator()
        input_args=['--syntax', '--service', SAMPLE_DIR+'samples/services/valid-syntax-tng/simplest-example.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_service_syntax_ok(self):
        validator = Validator()
        input_args=['--syntax', '--service', SAMPLE_DIR+'samples/services/valid-son/valid.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_service_syntax_ko_unexpected_field(self):
        validator = Validator()
        input_args=['--syntax', '--service', SAMPLE_DIR+'samples/services/invalid-syntax-tng/unexpected_field.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 1)

    def test_cli_validation_service_syntax_ko_required_properties(self):
        validator = Validator()
        input_args=['--syntax', '--service', SAMPLE_DIR+'samples/services/invalid-syntax-tng/required_properties.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 1)

    def test_cli_validation_function_integrity_ok(self):
        validator = Validator()
        input_args=['--integrity', '--function', SAMPLE_DIR+'samples/functions/valid-son/firewall-vnfd.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_function_integrity_ok_dext(self):
        validator = Validator()
        input_args=['--integrity', '--function', SAMPLE_DIR+'samples/functions/valid-son/', '--dext', 'yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_function_integrity_ko(self):
        validator = Validator()
        input_args=['--integrity', '--function', SAMPLE_DIR+'samples/functions/invalid_integrity-son/firewall-vnfd.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 1)

    def test_cli_validation_function_integrity_ko_dext(self):
        validator = Validator()
        input_args=['--integrity', '--function', SAMPLE_DIR+'samples/functions/invalid_integrity-son/', '--dext', 'yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 3)

    def test_cli_validation_service_integrity_ok(self):
        validator = Validator()
        input_args=['--integrity', '--service', SAMPLE_DIR+'samples/services/valid-son/valid.yml', \
                    '--dpath', SAMPLE_DIR+'samples/functions/valid-son/', '--dext', 'yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_service_topology_ok(self):
        validator = Validator()
        input_args=['--topology', '--service', SAMPLE_DIR+'samples/services/valid-son/valid.yml', \
                    '--dpath', SAMPLE_DIR+'samples/functions/valid-son/', '--dext', 'yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_function_topology_ok(self):
        validator = Validator()
        input_args=['--topology', '--function', SAMPLE_DIR+'samples/functions/valid-son/firewall-vnfd.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_function_topology_ok_dext(self):
        validator = Validator()
        input_args=['--topology', '--function', SAMPLE_DIR+'samples/functions/valid-son/', '--dext', 'yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 0)

    def test_cli_validation_function_topology_ko_dext(self):
        validator = Validator()
        input_args=['--topology', '--function', SAMPLE_DIR+'samples/functions/invalid_topology-son/firewall-vnfd.yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 1)

    def test_cli_validation_function_topology_ko_dext(self):
        validator = Validator()
        input_args=['--topology', '--function', SAMPLE_DIR+'samples/functions/invalid_topology-son', '--dext', 'yml']
        args=cli.parse_args(input_args)
        print("Test arguments: {}".format(args))
        result_validator = cli.dispatch(args,validator)
        self.assertEqual(result_validator.error_count, 1)

if __name__ == "__main__":
    unittest.main()
