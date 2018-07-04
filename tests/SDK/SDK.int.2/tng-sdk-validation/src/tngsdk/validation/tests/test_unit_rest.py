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
import json
import time
import ast
from unittest.mock import patch
from requests.exceptions import RequestException
# Do unit test of specific functions
#from tngsdk.validation.rest import app, on_unpackaging_done, on_packaging_done
from tngsdk.validation.rest import app

SAMPLES_DIR='src/tngsdk/validation/tests/'


# class MockResponse(object):
#         pass

#
# def mock_requests_post(url, json):
#     if url != "https://test.local:8000/cb":
#         raise RequestException("bad url")
#     if "event_name" not in json:
#         raise RequestException("bad request")
#     if "package_id" not in json:
#         raise RequestException("bad request")
#     if "package_location" not in json:
#         raise RequestException("bad request")
#     if "package_metadata" not in json:
#         raise RequestException("bad request")
#     if "package_process_uuid" not in json:
#         raise RequestException("bad request")
#     mr = MockResponse()
#     mr.status_code = 200
#     return mr


class TngSdkValidationRestTest(unittest.TestCase):

    def setUp(self):
        # configure mocks
        # self.patcher = patch("requests.post", mock_requests_post)
        # self.patcher.start()
        # configure flask
        app.config['TESTING'] = True
        app.cliargs = None
        self.app = app.test_client()

    # def tearDown(self):
    #     self.patcher.stop()

    # def test_validations_v1_endpoint(self):
    #     # do a malformed post
    #     r = self.app.post("/api/v1/validations")
    #     self.assertEqual(r.status_code, 400)
    #     # do a post with a real validation for function
    #     # w/o errors
    #     r = self.app.post("/api/v1/packages",
    #                       content_type="multipart/form-data",
    #                       data={"package": (
    #                           open("misc/5gtango-ns-package-example.tgo",
    #                                "rb"), "5gtango-ns-package-example.tgo"),
    #                             "skip_store": True})
    #     self.assertEqual(r.status_code, 200)
    #     rd = json.loads(r.get_data(as_text=True))
    #     self.assertIn("package_process_uuid", rd)
        # do a post with a real validation for service
        # w/o errors

        # do a post with a real validation for fucntion
        # w/o errors

        # do a post with a real validation for service
        # with errors

    def test_rest_validation_function_syntax_ok(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&function='+SAMPLES_DIR+'samples/functions/valid-syntax-tng/default-vnfd-tng.yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 0)

    def test_rest_validation_function_syntax_ok_dext(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&function='+SAMPLES_DIR+'samples/functions/valid-syntax-tng/&dext=yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 0)

    def test_rest_validation_function_syntax_ko(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&function='+SAMPLES_DIR+'samples/functions/invalid-syntax-tng/default-vnfd-tng.yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 1)

    def test_rest_validation_service_syntax_ok(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&service='+SAMPLES_DIR+'samples/services/valid-son/valid.yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 0)

    def test_rest_validation_service_syntax_ko(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&service='+SAMPLES_DIR+'samples/services/invalid-syntax-tng/unexpected_field.yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 1)

    def test_rest_validation_function_integrity_ok(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&function='+SAMPLES_DIR+'samples/functions/valid-son/firewall-vnfd.yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 0)

    def test_rest_validation_function_integrity_ok_dext(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&function='+SAMPLES_DIR+'samples/functions/valid-son/&&dext=yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 0)

    def test_rest_validation_function_integrity_ko(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&function='+SAMPLES_DIR+'samples/functions/invalid_integrity-son/firewall-vnfd.yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 1)

    def test_rest_validation_function_integrity_ko_dext(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&function='+SAMPLES_DIR+'samples/functions/invalid_integrity-son/&dext=yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 3)

    def test_rest_validation_service_integrity_ok(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&service='+SAMPLES_DIR+'samples/services/valid-son/valid.yml&dpath='+SAMPLES_DIR+'samples/functions/valid-son/&dext=yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 0)

    def test_rest_validation_service_integrity_ko(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&service='+SAMPLES_DIR+'samples/services/valid-son/valid.yml&dpath='+SAMPLES_DIR+'samples/functions/invalid_integrity-son/&dext=yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 3)

    def test_rest_validation_function_topology_ok(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&topology=true&function='+SAMPLES_DIR+'samples/functions/valid-son/firewall-vnfd.yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 0)

    def test_rest_validation_function_topology_ok_dext(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&topology=true&function='+SAMPLES_DIR+'samples/functions/valid-son/&dext=yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 0)

    def test_rest_validation_function_topology_ko(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&topology=true&function='+SAMPLES_DIR+'samples/functions/invalid_topology-son/firewall-vnfd.yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 1)

    def test_rest_validation_function_topology_ko_dext(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&topology=true&function='+SAMPLES_DIR+'samples/functions/invalid_topology-son/&dext=yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 1)

    def test_rest_validation_service_topology_ok(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&topology=true&service='+SAMPLES_DIR+'samples/services/valid-son/valid.yml&dpath='+SAMPLES_DIR+'samples/functions/valid-son/&dext=yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 0)

    def test_rest_validation_service_topology_ko(self):
        r = self.app.post('/api/v1/validations?sync=true&syntax=true&integrity=true&topology=true&service='+SAMPLES_DIR+'samples/services/valid-son/valid.yml&dpath='+SAMPLES_DIR+'samples/functions/invalid_topology-son/&dext=yml')
        data = r.data.decode('utf-8')
        d = ast.literal_eval(data)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(d['error_count'], 1)

if __name__ == "__main__":
    unittest.main()


# This examples can be useful to create the tests
#
#curl "http://localhost:5001/api/v1/validations?sync=true&syntax=true&integrity=true&function=src/tngsdk/validation/tests/samples/functions/valid-syntax-tng/default-vnfd-tng.yml"  -X POST

#curl "http://localhost:5001/api/v1/validations?sync=false&syntax=true&integrity=true&function=src/tngsdk/validation/tests/samples/functions/valid-syntax-tng/default-vnfd-tng.yml"  -X POST
#{
#    "error_message": "Asynchronous processing not yet implemented"
#}
#curl "http://localhost:5001/api/v1/validations?sync=true&syntax=true&integrity=true&function= src/tngsdk/validation/tests/samples/functions/valid-syntax-tng/default-vnfd-tng.yml"  -X POST
#<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
#        "http://www.w3.org/TR/html4/strict.dtd">
#<html>
#    <head>
#        <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
#        <title>Error response</title>
#    </head>
#    <body>
#        <h1>Error response</h1>
#        <p>Error code: 400</p>
#        <p>Message: Bad request syntax ('POST /api/v1/validations?sync=true&amp;syntax=true&amp;integrity=true&amp;function= src/tngsdk/validation/tests/samples/functions/valid-syntax-tng/default-vnfd-tng.yml HTTP/1.1').</p>
#        <p>Error code explanation: HTTPStatus.BAD_REQUEST - Bad request syntax or unsupported method.</p>
#    </body>
#</html>

# curl "http://localhost:5001/api/v1/validations?sync=true&syntax=true&integrity=true&service=src/tngsdk/validation/tests/samples/services/valid-syntax-tng/simplest-example.yml"  -X POST
# {
#     "validation_process_uuid": "test",
#     "status": 200,
#     "Number of errors": 2,
#     "Errors": [
#         {
#             "source_id": "./src/tngsdk/validation/tests/samples/functions/invalid-syntax-tng/invalid-tcpdump-vnfd-tng.yml",
#             "event_code": "evt_invalid_descriptor",
#             "level": "error",
#             "event_id": "./src/tngsdk/validation/tests/samples/functions/invalid-syntax-tng/invalid-tcpdump-vnfd-tng.yml",
#             "header": "Invalid descriptor",
#             "detail": [
#                 {
#                     "message": "Error parsing descriptor file: while parsing a block collection\n  in \"./src/tngsdk/validation/tests/samples/functions/invalid-syntax-tng/invalid-tcpdump-vnfd-tng.yml\", line 51, column 3\nexpected <block end>, but found '?'\n  in \"./src/tngsdk/validation/tests/samples/functions/invalid-syntax-tng/invalid-tcpdump-vnfd-tng.yml\", line 58, column 3",
#                     "detail_event_id": "./src/tngsdk/validation/tests/samples/functions/invalid-syntax-tng/invalid-tcpdump-vnfd-tng.yml"
#                 }
#             ]
#         },
#         {
#             "source_id": "eu.sonata-nfv.service-descriptor.simplest-example.0.2",
#             "event_code": "evt_nsd_itg_function_unavailable",
#             "level": "error",
#             "event_id": "eu.sonata-nfv.service-descriptor.simplest-example.0.2",
#             "header": "Function not available",
#             "detail": [
#                 {
#                     "message": "Failed to read service function descriptors",
#                     "detail_event_id": "eu.sonata-nfv.service-descriptor.simplest-example.0.2"
#                 }
#             ]
#         }
#     ]
# }

# curl "http://localhost:5001/api/v1/validations?sync=fal&syntax=true&integrity=true&service=src/tngsdk/validation/tests/samples/services/valid-syntax-tng/simplest-example.yml"  -X POST
# {
#     "errors": {
#         "sync": "If True indicates that the request will be handled synchronously"
#     },
#     "message": "Input payload validation failed"
# }
