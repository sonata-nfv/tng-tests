#!/usr/bin/python3

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


import argparse
import oyaml as yaml        # ordered yaml to avoid reordering of descriptors
import copy
import os
import logging
import coloredlogs


log = logging.getLogger(__name__)


def parse_args():
    parser = argparse.ArgumentParser(description='Generate NSD and VNFDs')
    parser.add_argument('-o', help='set relative output path',
                        required=False, default='.', dest='out_path')
    parser.add_argument('--debug', help='increases logging level to debug',
                        required=False, action='store_true')
    parser.add_argument('--tango', help='only generate 5GTANGO descriptors',
                        required=False, action='store_true')
    parser.add_argument('--osm', help='only generate OSM descriptors',
                        required=False, action='store_true')
    parser.add_argument('--author', help='set a specific NSD and VNFD author',
                        required=False, default='5GTANGO Developer', dest='author')
    parser.add_argument('--vendor', help='set a specific NSD and VNFD vendor',
                        required=False, default='eu.5gtango', dest='vendor')
    parser.add_argument('--name', help='set a specific NSD name',
                        required=False, default='tango-nsd', dest='name')
    parser.add_argument('--description', help='set a specific NSD description',
                        required=False, default='Default description',
                        dest='description')
    parser.add_argument('--vnfs', help='set a specific number of VNFs',
                        required=False, default=1, dest='vnfs')

    return parser.parse_args()


# generate 5GTANGO descriptors from the provided high-level arguments
def generate_tango(args):
    # load default descriptors (relative to file location, not curr directory)
    log.debug('Loading 5GTANGO default descriptors')
    descriptor_dir = os.path.join(os.path.dirname(__file__), 'default-descriptors')
    with open(os.path.join(descriptor_dir, 'tango_default_nsd.yml')) as f:
        tango_default_nsd = yaml.load(f)
    with open(os.path.join(descriptor_dir, 'tango_default_vnfd.yml')) as f:
        tango_default_vnfd = yaml.load(f)

    # generate VNFDs
    log.debug('Generating 5GTANGO VNFDs')
    vnfds = []
    tango_default_vnfd['author'] = args.author
    tango_default_vnfd['vendor'] = args.vendor
    for i in range(int(args.vnfs)):
        vnfd = copy.deepcopy(tango_default_vnfd)
        vnfd['name'] = 'default-vnf{}'.format(i)
        vnfds.append(vnfd)

    # generate NSD
    log.debug('Generating 5GTANGO NSD')
    nsd = tango_default_nsd
    nsd['author'] = args.author
    nsd['vendor'] = args.vendor
    nsd['name'] = args.name
    nsd['description'] = args.description

    # keep reusable parts of the default NSD that are independent from #VNFs
    # eg, there is always a mgmt vLink and a vLink from the input for vnf0
    # remove other stuff which will be replaced (vnf0-2-output vLink)
    del nsd['virtual_links'][2]
    del nsd['forwarding_graphs'][0]['constituent_virtual_links'][1]
    del nsd['forwarding_graphs'][0]['network_forwarding_paths'][0]['connection_points'][2:4]

    # now updated and extend the NSD
    for i, vnf in enumerate(vnfds):
        # list of involved VNFs
        # first entry already exists -> adjust, then append new ones
        if i > 0:
            nsd['network_functions'].append({})
        nsd['network_functions'][i]['vnf_id'] = 'vnf{}'.format(i)
        nsd['network_functions'][i]['vnf_name'] = vnf['name']
        nsd['network_functions'][i]['vnf_vendor'] = vnf['vendor']
        nsd['network_functions'][i]['vnf_version'] = vnf['version']

        # create corresponding vLinks
        # add vLink to next vnf
        if i < len(vnfds) - 1:
            nsd['virtual_links'].append({
                'id': 'vnf{}-2-vnf{}'.format(i, i+1),
                'connectivity_type': 'E-Line',
                'connection_points_reference': [
                    'vnf{}:output'.format(i), 'vnf{}:input'.format(i+1)
                ]
            })
        # for last vnf in chain, set vLink to output instead
        else:
            nsd['virtual_links'].append({
                'id': 'vnf{}-2-output'.format(i, i+1),
                'connectivity_type': 'E-Line',
                'connection_points_reference': [
                    'vnf{}:output'.format(i), 'output'
                ]
            })

        # add mgmt connection point (already exists for vnf0)
        if i > 0:
            nsd['virtual_links'][0]['connection_points_reference'].append(
                'vnf{}:mgmt'.format(i)
            )

    # adjust forwarding graph
    nsd['forwarding_graphs'][0]['number_of_virtual_links'] = len(vnfds) + 1
    # append new vLinks (skip mgmt and input-2-vnf0, which are already there)
    for i in range(2, len(nsd['virtual_links'])):
        nsd['forwarding_graphs'][0]['constituent_virtual_links'].append(
            nsd['virtual_links'][i]['id']
        )
    # append new vnfs
    for i in range(1, len(vnfds)):
        nsd['forwarding_graphs'][0]['constituent_vnfs'].append(
            nsd['network_functions'][i]['vnf_id']
        )

    # append in- and output of each vLink (keep input, vnf0:input, vnf0:output)
    pos = 3
    for i in range(2, len(nsd['virtual_links'])):
        nsd['forwarding_graphs'][0]['network_forwarding_paths'][0]['connection_points'].append({
            'connection_point_ref': nsd['virtual_links'][i]['connection_points_reference'][0],
            'position': pos
        })
        pos += 1
        nsd['forwarding_graphs'][0]['network_forwarding_paths'][0]['connection_points'].append({
            'connection_point_ref': nsd['virtual_links'][i]['connection_points_reference'][1],
            'position': pos
        })
        pos += 1

    log.info('Generated 5GTANGO descriptors at {}'.format(args.out_path))
    return nsd, vnfds


# generate OSM descriptors from the provided high-level arguments
def generate_osm(args):
    # load default descriptors (relative to file location, not curr directory)
    log.debug('Loading OSM default descriptors')
    descriptor_dir = os.path.join(os.path.dirname(__file__), 'default-descriptors')
    with open(os.path.join(descriptor_dir, 'osm_default_nsd.yml')) as f:
        osm_default_nsd = yaml.load(f)
    with open(os.path.join(descriptor_dir, 'osm_default_vnfd.yml')) as f:
        osm_default_vnfd = yaml.load(f)

    # generate VNFDs
    log.debug('Generating 5GTANGO VNFDs')
    vnfds = []
    for i in range(int(args.vnfs)):
        vnfd = copy.deepcopy(osm_default_vnfd)
        vnfd['vnfd-catalog']['vnfd'][0]['id'] = 'default-vnf{}'.format(i)
        vnfd['vnfd-catalog']['vnfd'][0]['name'] = 'default-vnf{}'.format(i)
        vnfd['vnfd-catalog']['vnfd'][0]['short-name'] = 'default-vnf{}'.format(i)
        vnfd['vnfd-catalog']['vnfd'][0]['vendor'] = args.vendor
        vnfds.append(vnfd)

    # generate NSD
    log.debug('Generating 5GTANGO NSD')
    nsd = osm_default_nsd['nsd-catalog']['nsd'][0]
    nsd['vendor'] = args.vendor
    nsd['id'] = args.name
    nsd['name'] = args.name
    nsd['description'] = args.description

    # skip first vnf
    for i, vnf in enumerate(vnfds):
        # updated existing entries for vnf0 and then append new ones
        if i > 0:
            nsd['constituent-vnfd'].append({})
            nsd['vld'][0]['vnfd-connection-point-ref'].append({})

        # list involved vnfs
        nsd['constituent-vnfd'][i]['member-vnf-index'] = i
        nsd['constituent-vnfd'][i]['vnfd-id-ref'] = vnf['vnfd-catalog']['vnfd'][0]['id']

        # create mgmt connection points
        nsd['vld'][0]['vnfd-connection-point-ref'][i]['member-vnf-index-ref'] = i
        nsd['vld'][0]['vnfd-connection-point-ref'][i]['vnfd-connection-point-ref'] = 'mgmt'
        nsd['vld'][0]['vnfd-connection-point-ref'][i]['vnfd-id-ref'] = vnf['vnfd-catalog']['vnfd'][0]['id']

    # create vlinks between vnfs
    for i in range(len(vnfds)-1):
        nsd['vld'].append({
            'id': 'vnf{}-2-vnf{}'.format(i, i+1),
            'name': 'vnf{}-2-vnf{}'.format(i, i+1),
            'vnfd-connection-point-ref': [
                {
                    'member-vnf-index-ref': i,
                    'vnfd-connection-point-ref': 'output',
                    'vnfd-id-ref': vnfds[i]['vnfd-catalog']['vnfd'][0]['id']
                },
                {
                    'member-vnf-index-ref': i+1,
                    'vnfd-connection-point-ref': 'input',
                    'vnfd-id-ref': vnfds[i+1]['vnfd-catalog']['vnfd'][0]['id']
                }
            ]
        })

    log.info('Generated OSM descriptors at {}'.format(args.out_path))
    return nsd, vnfds


# save the generated descriptors in the specified folder; add a prefix for each flavor
def save_descriptors(nsd, vnfds, flavor, folder='.'):
    # create dir if it doesn't exist
    if not os.path.exists(folder):
        os.makedirs(folder)

    # dump generated nsd and vnfds
    outfile = os.path.join(folder, '{}_nsd.yml'.format(flavor))
    with open(outfile, 'w', newline='') as f:
        yaml.dump(nsd, f, default_flow_style=False)
    for i, vnf in enumerate(vnfds):
        outfile = os.path.join(folder, '{}_vnfd{}.yml'.format(flavor, i))
        with open(outfile, 'w', newline='') as f:
            yaml.dump(vnf, f, default_flow_style=False)


def generate():
    args = parse_args()
    if args.debug:
        coloredlogs.install(level='DEBUG')
    else:
        coloredlogs.install(level='INFO')

    # generate and save tango descriptors
    if not args.osm:
        nsd, vnfds = generate_tango(args)
        save_descriptors(nsd, vnfds, 'tango', args.out_path)

    # generate and save osm descriptors
    if not args.tango:
        nsd, vnfds = generate_osm(args)
        save_descriptors(nsd, vnfds, 'osm', args.out_path)


if __name__ == '__main__':
    generate()
