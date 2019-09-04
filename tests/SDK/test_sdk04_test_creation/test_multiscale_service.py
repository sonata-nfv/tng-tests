#  Copyright (c) 2015 SONATA-NFV, 5GTANGO
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
# Neither the name of the SONATA-NFV, 5GTANGO
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


import pytest
import time
from functools import wraps

from tangotest.vim.emulator import Emulator


def deploy_service(scale, vim):
    ts = time.time()
    vim.add_instance_from_image('client', 'tangotestclient', {'emu0': '10.0.0.2/24'})
    
    lb_network = {'output{}'.format(i): '10.1.{}.4/24'.format(i) for i in range(scale)}
    lb_network['input'] = '10.0.0.4/24'
    vim.add_instance_from_image('lb', 'tangotestlb', lb_network)
    vim.add_link('client', 'emu0', 'lb', 'input')
    
    server_network = {'input{}'.format(i): '10.1.{}.6/24'.format(i) for i in range(scale)}
    vim.add_instance_from_image('server', 'tangotestserver', server_network)
    
    for i in range(scale):
        snort_name = 'snort{}'.format(i)
        vim.add_instance_from_image(snort_name, 'tangotestsnort', ['input', 'output'])
        vim.add_link('lb', 'output{}'.format(i), snort_name, 'input')
        vim.add_link(snort_name, 'output', 'server', 'input{}'.format(i))
        vim.lb.execute('./add-server 10.1.{}.6'.format(i))

    te = time.time()
    with open('timing.txt', 'a+') as logfile:
        logfile.write('deploy, scale: {}, time: {}\n'.format(scale, te-ts))


@pytest.mark.parametrize('scale', range(1, 11))
def test_service(scale):
    with Emulator() as vim:
        deploy_service(scale, vim)
        ts = time.time()
        ip = vim.lb.get_ip('input')

        bad_calls = 2 * scale
        bad_cmd = 'curl -s {}/restricted/'.format(ip)
        good_calls = scale
        good_cmd = 'curl -s {}'.format(ip)
        
        for _ in range(bad_calls):
            print('bad call')
            vim.client.execute(bad_cmd)
 
        for _ in range(good_calls):
            print('good call')
            exec_code, output = vim.client.execute(good_cmd)
            assert exec_code == 0
            assert output.strip() == 'Home Page'
        
        time.sleep(1)
        expected_alerts_length = bad_calls // scale
        for i in range(scale):
            alert_records = vim.instances['snort{}'.format(i)].get_file('/snort-logs/alert').splitlines()
            assert len([i for i in alert_records if 'Requested restricted content' in i]) == expected_alerts_length
        te = time.time()
        with open('timing.txt', 'a+') as logfile:
            logfile.write('test, scale: {}, time: {}\n'.format(scale, te-ts))
