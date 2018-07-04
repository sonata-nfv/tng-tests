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

import os
import logging
import networkx as nx
import validators
import requests
from collections import OrderedDict
# importing the local event module, fix this ASAP
#from .event import *
#import util
from tngsdk.validation.util import descriptor_id, read_descriptor_file
#from util import read_descriptor_file, descriptor_id
from tngsdk.validation import event


log = logging.getLogger(__name__)
evtlog = event.get_logger('validator.events')


class DescriptorStorage(object):

    def __init__(self):
        """
        Initialize an object to store descriptors.
        """
        # dictionaries for services, functions and units
        self._packages = {}
        self._services = {}
        self._functions = {}
        self._units = {}

    @property
    def packages(self):
        """
        Provides the stored packages.
        :return: dictionary of packages.
        """
        return self._packages

    @property
    def services(self):
        """
        Provides the stored services.
        :return: dictionary of services.
        """
        return self._services

    @property
    def functions(self):
        """
        Provides the stored functions.
        :return: dictionary of functions.
        """
        return self._functions

    def service(self, sid):
        """
        Obtain the service for the provided service id
        :param sid: service id
        :return: service descriptor object
        """
        if sid not in self.services:
            log.error("Service id='{0}' is not stored.".format(sid))
            return
        return self.services[sid]

    def create_package(self, descriptor_file):
        """
        Create and store a package based on the provided descriptor filename.
        If a package is already stored with the same id, it will return the
        stored package.
        :param descriptor_file: package descriptor filename
        :return: created package object or, if id exists, the stored package.
        """
        if not os.path.isfile(descriptor_file):
            return
        new_package = Package(descriptor_file)
        if new_package.id in self._packages:
            return self._packages[new_package.id]

        self._packages[new_package.id] = new_package
        return new_package

    def create_service(self, descriptor_file):
        """
        Create and store a service based on the provided descriptor filename.
        If a service is already stored with the same id, it will return the
        stored service.
        :param descriptor_file: service descriptor filename
        :return: created service object or, if id exists, the stored service.
        """
        if not os.path.isfile(descriptor_file):
            return
        new_service = Service(descriptor_file)
        if not new_service.content or not new_service.id:
            return

        if new_service.id in self._services:
            return self._services[new_service.id]

        self._services[new_service.id] = new_service
        return new_service

    def function(self, fid):
        """
        Obtain the function for the provided function id
        :param fid: function id
        :return: function descriptor object
        """
        if fid not in self._functions[fid]:
            log.error("Function id='{0}' is not stored.".format(fid))
            return
        return self.functions[fid]

    def create_function(self, descriptor_file):
        """
        Create and store a function based on the provided descriptor filename.
        If a function is already stored with the same id, it will return the
        stored function.
        :param descriptor_file: function descriptor filename
        :return: created function object or, if id exists, the stored function.
        """
        if not os.path.isfile(descriptor_file):
            return
        new_function = Function(descriptor_file)
        if new_function.id in self._functions.keys():
            return self._functions[new_function.id]

        self._functions[new_function.id] = new_function
        return new_function


class Node:
    def __init__(self, nid):
        """
        Initialize a node object.
        A node holds multiple network connection points
        :param nid: node id
        """
        self._id = nid
        self._connection_points = []

    @property
    def id(self):
        """
        Identifier of the node.
        :return: node id
        """
        return self._id

    @property
    def connection_points(self):
        """
        Provides a list of interfaces associated with the node.
        :return: interface list
        """
        return self._connection_points

    @connection_points.setter
    def connection_points(self, value):
        self._connection_points = value

    def add_connection_point(self, cp):
        """
        Associate a new interface to the node.
        :param cp: connection point ID
        """
        if cp in self.connection_points:
            evtlog.log("Duplicate connection point",
                       "The CP id='{0}' is already stored in node "
                       "id='{1}'".format(cp, self.id),
                       self.id,
                       'evt_duplicate_cpoint')
            return

        # check if connection point has the correct format
        s_cp = cp.split(':')
        if len(s_cp) != 1:
            evtlog.log("Invalid_connection_point",
                       "The CP id='{0}' is invalid. The separator ':' is "
                       "reserved to reference connection points"
                       .format(cp),
                       self.id,
                       'evt_invalid_cpoint')
            return

        log.debug("Node id='{0}': adding connection point '{1}'"
                  .format(self.id, cp))

        self._connection_points.append(cp)

        return True


class VLink:
    def __init__(self, vl_id, cpr_u, cpr_v):
        """
        Initialize a vlink object.
        A vlink defines a connection between two connection_points.
        :param vl_id: link id
        :param cpr_u: connection point reference u
        :param cpr_v: connection point reference v
        """
        self._id = vl_id
        self._cpr_pair = [cpr_u, cpr_v]

    def __repr__(self):
        return self.__str__()

    def __str__(self):
        return "{} -- {}".format(self.id, self.cpr_u, self.cpr_v)

    @property
    def id(self):
        return self._id

    @property
    def connection_point_refs(self):
        """
        The two connection points references composing the vlink
        in a list format [u, v]
        :return: list (size 2) of connection point references
        """
        return self._cpr_pair

    @property
    def cpr_u(self):
        """
        Connection point reference u
        """
        return self._cpr_pair[0]

    @property
    def cpr_v(self):
        """
        Connection point reference v
        """
        return self._cpr_pair[1]


class VBridge:
    def __init__(self, vb_id, cp_refs):
        """
        Initialize a vbridge object.
        A bridge contains a list of N associated connection point reference.
        """
        assert vb_id
        assert cp_refs

        self._id = vb_id
        self._cp_refs = cp_refs

    def __repr__(self):
        return self.__str__()

    def __str__(self):
        return "{}".format(self.connection_point_refs)

    @property
    def id(self):
        return self._id

    @property
    def connection_point_refs(self):
        return self._cp_refs


class Descriptor(Node):
    def __init__(self, descriptor_file):
        """
        Initialize a generic descriptor object.
        This object inherits the node object.
        All descriptor objects contains the following properties:
            - id
            - content: descriptor dictionary
            - filename: filename of the descriptor
        :param descriptor_file: filename of the descriptor
        """
        self._id = None
        self._content = None
        self._filename = None
        self.filename = descriptor_file
        super().__init__(self.id)
        self._complete_graph = None
        self._graph = None
        self._vlinks = {}
        self._vbridges = {}

    @property
    def id(self):
        """
        Identification of descriptor
        :return: descriptor id
        """
        return self._id

    @property
    def content(self):
        """
        Descriptor dictionary.
        :return: descriptor dict
        """
        return self._content

    @content.setter
    def content(self, value):
        """
        Sets the descriptor dictionary.
        This modification will impact the id of the descriptor.
        :param value: descriptor dict
        """
        self._content = value
        self._id = descriptor_id(self._content)

    @property
    def filename(self):
        """
        Filename of the descriptor
        :return: descriptor filename
        """
        return self._filename

    @filename.setter
    def filename(self, value):
        """
        Sets the descriptor filename.
        This modification will impact the content and id of the descriptor.
        :param value: descriptor filename
        """
        self._filename = value
        content = read_descriptor_file(self._filename)
        if content:
            self.content = content

    @property
    def vlinks(self):
        """
        Provides the links associated with the descriptor.
        :return: dictionary of link objects
        """
        return self._vlinks

    @property
    def vbridges(self):
        """
        Provides the bridges associated with the descriptor.
        :return: dictionary of vbridge objects
        """
        return self._vbridges

    @property
    def vlink_cp_refs(self):
        vlink_cps = []
        for vl_id, vl in self.vlinks.items():
            vlink_cps += vl.connection_point_refs
        return vlink_cps

    @property
    def vbridge_cp_refs(self):
        vbridge_cp_references = []
        for vb_id, vb in self.vbridges.items():
            vbridge_cp_references += vb.connection_point_refs
        return vbridge_cp_references

    @property
    def graph(self):
        """
        Network topology graph of the descriptor.
        :return: topology graph (networkx.Graph)
        """
        return self._graph

    @graph.setter
    def graph(self, value):
        """
        Sets the topology graph of the descriptor.
        :param value: topology graph (networkx.Graph)
        :return:
        """
        self._graph = value

    @property
    def complete_graph(self):
        return self._complete_graph

    @complete_graph.setter
    def complete_graph(self, value):
        self._complete_graph = value

    def load_connection_points(self):
        """
        Load connection points of the descriptor.
        It reads the section 'connection_points' of the descriptor contents.
        """
        if 'connection_points' not in self.content:
            return
        for cp in self.content['connection_points']:
            if not self.add_connection_point(cp['id']):
                return
        return True

    def add_vbridge(self, vb_id, cp_refs):
        """
        Add vbridge to the descriptor.
        """
        # check number of connection point references
        if len(cp_refs) < 1:
            evtlog.log("Bad number of connection points",
                       "The vlink id='{0}' must have at lease 1 connection "
                       "point reference"
                       .format(vb_id),
                       self.id,
                       'evt_invalid_vlink')
            return

        # check for duplicate virtual links
        if vb_id in self.vlinks.keys() or vb_id in self.vbridges.keys():
            evtlog.log("Duplicate virtual link",
                       "The vlink id='{0}' is already defined"
                       .format(vb_id),
                       self.id,
                       'evt_duplicate_vlink')
            return

        # check connection point reference format
        for cp in cp_refs:
            s_cp = cp.split(':')
            if len(s_cp) > 2:
                evtlog.log("Invalid connection point reference",
                           "The connection point reference '{0}' of vlink"
                           " id='{1}' has an incorrect format: found multiple "
                           "separators ':'"
                           .format(cp, vb_id),
                           self.id,
                           'evt_invalid_cpoint_ref')
                return

        self._vbridges[vb_id] = VBridge(vb_id, cp_refs)
        return True

    def add_vlink(self, vl_id, cp_refs):
        """
        Add vlink to the descriptor.
        """
        # check number of connection point references
        if len(cp_refs) != 2:
            evtlog.log("Bad number of connection points",
                       "The vlink id='{0}' must have exactly 2 connection "
                       "point references"
                       .format(vl_id),
                       self.id,
                       'evt_invalid_vlink')
            return

        # check for duplicate virtual links
        if vl_id in self.vlinks.keys() or vl_id in self.vbridges.keys():
            evtlog.log("Duplicate virtual link",
                       "The vlink id='{0}' is already defined"
                       .format(vl_id),
                       self.id,
                       'evt_duplicate_vlink')
            return

        # check connection point reference format
        for cp in cp_refs:
            s_cp = cp.split(':')
            if len(s_cp) > 2:
                evtlog.log("Invalid connection point reference",
                           "The connection point reference '{0}' of vlink"
                           " id='{1}' has an incorrect format: found multiple "
                           "separators ':'"
                           .format(cp, vl_id),
                           self.id,
                           'evt_invalid_cpoint_ref')
                return

        self._vlinks[vl_id] = VLink(vl_id, cp_refs[0], cp_refs[1])
        return True

    def load_virtual_links(self):
        """
        Load 'virtual_links' section of the descriptor.
        - 'e-line' virtual links will be stored in Link objects
        - 'e-lan' virtual links will be stored in Bridge objects
        """
        if 'virtual_links' not in self.content:
            return

        for vl in self.content['virtual_links']:
            if not vl['id']:
                evtlog.log("Missing virtual link ID",
                           "A virtual link is missing its ID",
                           self.id,
                           'evt_invalid_vlink')
                return

            vl_type = vl['connectivity_type'].lower()
            if vl_type == 'e-line':
                if not self.add_vlink(vl['id'],
                                      vl['connection_points_reference']):
                    return

            if vl_type == 'e-lan':
                if not self.add_vbridge(vl['id'],
                                        vl['connection_points_reference']):
                    return

        return True

    def unused_connection_points(self):
        """
        Provides a list of connection points that are not referenced by
        'virtual_links'. Should only be invoked after connection points
        are loaded.
        """
        unused_cps = []
        for cp in self.connection_points:
            if cp not in self.vlink_cp_refs and \
                    cp not in self.vbridge_cp_refs:
                unused_cps.append(cp)
        return unused_cps


class Package(Descriptor):

    def __init__(self, descriptor_file):
        """
        Initialize a package object. This inherits the descriptor object.
        :param descriptor_file: descriptor filename
        """
        super().__init__(descriptor_file)

    @property
    def entry_service_file(self):
        """
        Provides the entry point service of the package.
        :return: service id
        """
        return self.content['entry_service_template'] if \
            'entry_service_template' in self.content else None

    @property
    def service_descriptors(self):
        """
        Provides a list of the service descriptor file names, referenced in
        the package.
        :return: list of service descriptor file names
        """
        service_list = []
        for item in self.content['package_content']:
            if item['content-type'] == \
                    'application/sonata.service_descriptor':
                service_list.append(item['name'])
        return service_list

    @property
    def function_descriptors(self):
        """
        Provides a list of the service descriptor file names, referenced in
        the package.
        :return: list of function descriptor file names
        """
        function_list = []
        for item in self.content['package_content']:
            if item['content-type'] == \
                    'application/sonata.function_descriptor':
                function_list.append(item['name'])
        return function_list

    @property
    def descriptors(self):
        """
        Provides a list of the descriptors, referenced in the package.
        :return: list of descriptor file names
        """
        return self.service_descriptors + self.function_descriptors

    def md5(self, descriptor_file):
        """
        Retrieves the MD5 hash defined in the package content of the specified
        descriptor
        :param descriptor_file: descriptor filename
        :return: md5 hash if descriptor found, None otherwise
        """
        descriptor_file = '/' + descriptor_file
        for item in self.content['package_content']:
            if item['name'] == descriptor_file:
                return item['md5']


class Service(Descriptor):

    def __init__(self, descriptor_file):
        """
        Initialize a service object. This inherits the descriptor object.
        :param descriptor_file: descriptor filename
        """
        super().__init__(descriptor_file)
        self._functions = {}
        self._vnf_id_map = {}
        self._fw_graphs = list()

    @property
    def functions(self):
        """
        Provides the functions specified in the service.
        :return: functions dict
        """
        return self._functions

    @property
    def fw_graphs(self):
        """
        Provides the forwarding paths specified in the service.
        :return: forwarding paths dict
        """
        return self._fw_graphs

    @property
    def all_function_connection_points(self):
        func_cps = []
        for fid, f in self.functions.items():
            func_cps += f.connection_points

        return func_cps

    def mapped_function(self, vnf_id):
        """
        Provides the function associated with a 'vnf_id' defined in the
        service content.
        :param vnf_id: vnf id
        :return: function object
        """
        if vnf_id not in self._vnf_id_map or self._vnf_id_map[vnf_id] not in\
                self._functions:
            return
        return self._functions[self._vnf_id_map[vnf_id]]

    def vnf_id(self, func):
        """
        Provides the vnf id associated with the provided function.
        :param func: function object
        :return: vnf id
        """
        for vnf_id, fid in self._vnf_id_map.items():
            if fid == func.id:
                return vnf_id
        return

    def associate_function(self, func, vnf_id):
        """
        Associate a function to the service.
        :param func: function object
        :param vnf_id: vnf id, defined in the service descriptor content
        """
        if type(func) is not Function:
            log.error("The function (VNF) id='{0}' has an invalid type"
                      .format(func.id))
            return

        if func.id in self.functions:
            log.error("The function (VNF) id='{0}' is already associated with "
                      "service id='{1}'".format(func.id, self.id))
            return

        log.debug("Service '{0}': associating function id='{1}' with vnf_id="
                  "'{2}'".format(self.id, func.id, vnf_id))

        self._functions[func.id] = func
        self._vnf_id_map[vnf_id] = func.id

    def build_topology_graph(self, level=1, bridges=False,
                             vdu_inner_connections=True):
        """
        Build the network topology graph of the service.
        :param level: indicates the granulariy of the graph
                    0: service level (does not show VNF interfaces)
                    1: service level (with VNF interfaces) - default
                    2: VNF level (showing VDUs but not VDU interfaces)
                    3: VDU level (with VDU interfaces)
        :param bridges: indicates whether bridges should be included in
                        the graph
        :param vdu_inner_connections: indicates whether VDU connection points
                                      should be internally connected
        """
        assert 0 <= level <= 3  # level must be 0, 1, 2, 3

        graph = nx.Graph()

        def_node_attrs = {'label': '',
                          'level': level,
                          'parent_id': self.id,
                          'type': ''  # 'iface' | 'br-iface' | 'bridge'
                          }

        def_link_attrs = {'label': '',
                          'level': '',
                          'type': ''  # 'iface' | 'br-iface' | 'vdu_in'
                          }

        # assign nodes from service connection points
        connection_point_refs = self.vlink_cp_refs
        if bridges:
            connection_point_refs += self.vbridge_cp_refs

        for cpr in connection_point_refs:
            node_attrs = def_node_attrs.copy()
            node_attrs['label'] = cpr
            s_cpr = cpr.split(':')
            func = self.mapped_function(s_cpr[0])
            if len(s_cpr) > 1 and func:

                node_attrs['parent_id'] = self.id
                node_attrs['level'] = 1
                node_attrs['node_id'] = func.id
                node_attrs['node_label'] = func.content['name']

            else:
                node_attrs['parent_id'] = ""
                node_attrs['level'] = 0
                node_attrs['node_id'] = self.id
                node_attrs['node_label'] = self.content['name']

            node_attrs['label'] = s_cpr[1] if len(s_cpr) > 1 else cpr

            if cpr in self.vlink_cp_refs:
                node_attrs['type'] = 'iface'
            elif cpr in self.vbridge_cp_refs:
                node_attrs['type'] = 'br-iface'

            graph.add_node(cpr, attr_dict=node_attrs)

        prefixes = []
        # assign sub-graphs of functions
        for fid, func in self.functions.items():
            # done to work with current descriptors of sonata demo
            prefix_map = {}
            prefix = self.vnf_id(func)

            if level <= 2:
                func.graph = func.build_topology_graph(
                    parent_id=self.id,
                    bridges=bridges,
                    level=0,
                    vdu_inner_connections=vdu_inner_connections)
            else:
                func.graph = func.build_topology_graph(
                    parent_id=self.id,
                    bridges=bridges,
                    level=1,
                    vdu_inner_connections=vdu_inner_connections)

            if level == 0:
                for node in func.graph.nodes():
                    node_tokens = node.split(':')
                    if len(node_tokens) > 1 and node in graph.nodes():
                        graph.remove_node(node)
                    else:
                        pn = prefix + ':' + node
                        if graph.has_node(pn):
                            graph.remove_node(pn)
                prefixes.append(prefix)

            elif level == 1:
                prefixes.append(prefix)

            elif level == 2:
                for node in func.graph.nodes():
                    s_node = node.split(':')
                    if len(s_node) > 1:
                        prefix_map[node] = prefix + ':' + s_node[0]
                    else:
                        prefix_map[node] = prefix + ':' + node

                re_f_graph = nx.relabel_nodes(func.graph, prefix_map,
                                              copy=True)
                graph.add_nodes_from(re_f_graph.nodes(data=True))
                graph.add_edges_from(re_f_graph.edges(data=True))

            elif level == 3:
                for node in func.graph.nodes():
                    s_node = node.split(':')
                    if node in func.connection_points and len(s_node) > 1:
                        prefix_map[node] = node
                    else:
                        prefix_map[node] = prefix + ':' + node

                re_f_graph = nx.relabel_nodes(func.graph, prefix_map,
                                              copy=True)
                graph.add_nodes_from(re_f_graph.nodes(data=True))
                graph.add_edges_from(re_f_graph.edges(data=True))

        # build vlinks topology graph
        if not self.vlinks and not self.vbridges:
            log.warning("No links were found")

        for vl_id, vl in self.vlinks.items():

            if level >= 1:
                cpr_u = vl.cpr_u
                cpr_v = vl.cpr_v

            elif level == 0:
                cpr_u = vl.cpr_u.split(':')
                cpr_v = vl.cpr_v.split(':')

                if len(cpr_u) > 1 and cpr_u[0] in prefixes:
                    cpr_u = cpr_u[0]
                else:
                    cpr_u = vl.cpr_u

                if len(cpr_v) > 1 and cpr_v[0] in prefixes:
                    cpr_v = cpr_v[0]
                else:
                    cpr_v = vl.cpr_v
            else:
                return

            link_attrs = def_link_attrs.copy()
            link_attrs['label'] = vl.id
            link_attrs['level'] = 0 if level == 0 else 1
            link_attrs['type'] = 'iface'
            graph.add_edge(cpr_u, cpr_v, attr_dict=link_attrs)

        # build vbridges topology graph
        if bridges:
            for vb_id, vb in self.vbridges.items():
                brnode = 'br-' + vb_id
                node_attrs = def_node_attrs.copy()
                node_attrs['label'] = brnode
                node_attrs['level'] = 1
                node_attrs['type'] = 'bridge'

                # add 'router' node for this bridge
                graph.add_node(brnode, attr_dict=node_attrs)
                for cp in vb.connection_point_refs:
                    if level >= 1:
                        s_cp = cp
                    elif level == 0:
                        s_cp = cp.split(':')
                        if len(s_cp) > 1 and s_cp[0] in prefixes:
                            s_cp = s_cp[0]
                        else:
                            s_cp = cp
                    else:
                        return

                    link_attrs = def_link_attrs
                    link_attrs['label'] = vb_id
                    link_attrs['level'] = 0 if level == 0 else 1
                    link_attrs['type'] = 'br-iface'
                    graph.add_edge(brnode, s_cp, attr_dict=link_attrs)

        # inter-connect VNF interfaces
        if level == 1:
            for node_u in graph.nodes():
                node_u_tokens = node_u.split(':')

                if len(node_u_tokens) > 1 and node_u_tokens[0] in prefixes:

                    for node_v in graph.nodes():
                        if node_u == node_v:
                            continue
                        node_v_tokens = node_v.split(':')
                        if len(node_v_tokens) > 1 and \
                                node_v_tokens[0] == node_u_tokens[0]:

                            # verify if these interfaces are connected
                            func = self.mapped_function(node_v_tokens[0])

                            if func.graph.has_node(node_u_tokens[1]):
                                node_u_c = node_u_tokens[1]
                            elif func.graph.has_node(node_u):
                                node_u_c = node_u
                            else:
                                continue

                            if func.graph.has_node(node_v_tokens[1]):
                                node_v_c = node_v_tokens[1]
                            elif func.graph.has_node(node_v):
                                node_v_c = node_v
                            else:
                                continue

                            if nx.has_path(func.graph, node_u_c, node_v_c):
                                link_attrs = def_link_attrs
                                link_attrs['label'] = node_u + '-' + node_v
                                link_attrs['level'] = 1
                                link_attrs['type'] = 'iface'
                                graph.add_edge(node_u, node_v,
                                               attr_dict=link_attrs)

        return graph

    def load_forwarding_graphs(self):
        """
        Load all forwarding paths of all forwarding graphs, defined in the
        service content.
        """
        for fgraph in self.content['forwarding_graphs']:
            s_fwgraph = dict()
            s_fwgraph['fg_id'] = fgraph['fg_id']
            s_fwgraph['fw_paths'] = list()

            for fpath in fgraph['network_forwarding_paths']:
                s_fwpath = dict()
                s_fwpath['fp_id'] = fpath['fp_id']

                path_dict = {}
                for cp in fpath['connection_points']:
                    cpr = cp['connection_point_ref']
                    s_cpr = cpr.split(':')
                    pos = cp['position']

                    if len(s_cpr) == 1 and cpr not in self.connection_points:
                        evtlog.log("Undefined connection point",
                                   "Connection point '{0}' of forwarding path "
                                   "'{1}' is not defined"
                                   .format(cpr, fpath['fp_id']),
                                   self.id,
                                   'evt_nsd_top_fwgraph_cpoint_undefined')
                        return
                    elif len(s_cpr) == 2:
                        # get corresponding function
                        func = self.mapped_function(s_cpr[0])
                        if not func or (func and s_cpr[1]
                                        not in func.connection_points):
                            evtlog.log("Undefined connection point",
                                       "Connection point '{0}' of forwarding "
                                       "path '{1}' is not defined"
                                       .format(cpr, fpath['fp_id']),
                                       self.id,
                                       'evt_nsd_top_fwgraph_cpoint_undefined')
                            return

                    if pos in path_dict:
                        evtlog.log("Duplicate reference in FG",
                                   "Duplicate referenced position '{0}' "
                                   "in forwarding path id='{1}'. Ignoring "
                                   "connection point: '{2}'"
                                   .format(pos, fpath['fp_id'],
                                           path_dict[pos]),
                                   self.id,
                                   'evt_nsd_top_fwgraph_position_duplicate')
                    path_dict[pos] = cpr
                d = OrderedDict(sorted(path_dict.items(),
                                       key=lambda t: t[0]))

                s_fwpath['path'] = list(d.values())
                s_fwgraph['fw_paths'].append(s_fwpath)

            self._fw_graphs.append(s_fwgraph)

        return True

    def _cp_in_functions(self, iface):
        """
        Indicates whether the provided connection point is defined in the
        functions of the service.
        :param iface: interface
        :return: True, if a functions contains the interface
                 False, otherwise.
        """
        iface_tokens = iface.split(':')
        if len(iface_tokens) != 2:
            return False
        func = self.mapped_function(iface_tokens[0])
        if not func:
            return False
        if (iface_tokens[1] not in func.interfaces and
                iface not in func.interfaces):
            return False

        return True

    def trace_path(self, path):
        """
        Trace a forwarding path along the service topology.
        This function returns a list with the visited interfaces. In cases
        where the path contains 'impossible' links it will add the 'BREAK'
        keyword in the according position of the trace list.
        :param path: forwarding path ordered interface list
        :return: trace list
        """
        trace = []
        for x in range(len(path)-1):
            trace.append(path[x])
            if not self._graph.has_node(path[x]):
                trace.append("BREAK")
                continue
            neighbours = self._graph.neighbors(path[x])
            if path[x+1] not in neighbours:
                trace.append("BREAK")
        trace.append(path[-1])
        return trace

    def trace_path_pairs(self, path):
        trace = []
        for x in range(0, len(path), 2):
            if x+1 >= len(path):
                node_pair = {'break': False, 'from': path[x], 'to': None}
            else:
                node_pair = {'break': False, 'from': path[x], 'to': path[x+1]}

                if path[x] not in self.graph.nodes() or \
                        path[x+1] not in self._graph.neighbors(path[x]):
                    node_pair['break'] = True
            trace.append(node_pair)
        return trace

    def undeclared_connection_points(self):
        """
        Provides a list of connection points that are referenced in
        'virtual_links' section but not declared in 'connection_points'
        of the Service or its Functions.
        """
        target_cp_refs = self.vlink_cp_refs + self.vbridge_cp_refs

        undeclared_cps = []
        for cpr in target_cp_refs:
            cpr_split = cpr.split(':')
            if len(cpr_split) == 1 and cpr not in self.connection_points:
                undeclared_cps.append(cpr)
            else:
                f = self.mapped_function(cpr_split[0])
                if f and cpr_split[1] not in f.connection_points:
                    undeclared_cps.append(cpr)

        return undeclared_cps


class Function(Descriptor):

    def __init__(self, descriptor_file):
        """
        Initialize a function object. This inherits the descriptor object.
        :param descriptor_file: descriptor filename
        """
        super().__init__(descriptor_file)
        self._units = {}

    @property
    def units(self):
        """
        Provides the unit objects associated with the function.
        :return: units dict
        """
        return self._units

    def associate_unit(self, unit):
        """
        Associate a unit to the function.
        :param unit: unit object
        """
        if type(unit) is not Unit:
            return

        if unit.id in self.units:
            log.error("The unit (VDU) id='{0}' is already associated with "
                      "function (VNF) id='{1}'".format(unit.id, self.id))
            return

        self._units[unit.id] = unit

    def load_units(self):
        """
        Load units of the function descriptor content, section
        'virtual_deployment_units'
        """
        if 'virtual_deployment_units' not in self.content:
            log.error("Function id={0} is missing the "
                      "'virtual_deployment_units' section"
                      .format(self.id))
            return

        for vdu in self.content['virtual_deployment_units']:
            unit = Unit(vdu['id'])
            self.associate_unit(unit)

            # Check vm image URLs
            # only perform a check if vm_image is a URL
            vdu_image_path = vdu['vm_image']
            if validators.url(vdu_image_path):  # Check if is URL/URI.
                try:
                    # Check if the image URL is accessible
                    # within a short time interval
                    requests.head(vdu_image_path, timeout=1)

                except (requests.Timeout, requests.ConnectionError):

                    evtlog.log("VDU image not found",
                               "Failed to verify the existence of VDU image at"
                               " the address '{0}'. VDU id='{1}'"
                               .format(vdu_image_path, vdu['id']),
                               self.id,
                               'evt_vnfd_itg_vdu_image_not_found')
        return True

    def load_unit_connection_points(self):
        """
        Load connection points of the units of the function.
        """
        for vdu in self.content['virtual_deployment_units']:
            if vdu['id'] not in self.units.keys():
                log.error("Unit id='{0}' is not associated with function "
                          "id='{1}".format(vdu['id'], self.id))
                return

            unit = self.units[vdu['id']]

            for cp in vdu['connection_points']:
                unit.add_connection_point(cp['id'])

        return True

    def build_topology_graph(self, bridges=False, parent_id='', level=0,
                             vdu_inner_connections=True):
        """
        Build the network topology graph of the function.
        :param bridges: indicates if bridges should be included in the graph
        :param parent_id: identify the parent service of this function
        :param level: indicates the granularity of the graph
                    0: VNF level (showing VDUs but not VDU connection points)
                    1: VDU level (with VDU connection points)
        :param vdu_inner_connections: indicates whether VDU connection points
                                      should be internally connected
        """
        graph = nx.Graph()

        def_node_attrs = {'label': '',
                          'level': level,
                          'parent_id': self.id,
                          'type': ''  # 'iface' | 'br-iface' | 'bridge'
                          }
        def_edge_attrs = {'label': '',
                          'level': '',
                          'type': ''}

        # assign nodes from function

        cp_refs = self.vlink_cp_refs

        if bridges:
            cp_refs += self.vbridge_cp_refs
        
        for cpr in cp_refs:
            node_attrs = def_node_attrs.copy()
            s_cpr = cpr.split(':')
            unit = self.units[s_cpr[0]] if s_cpr[0] in self.units else None
            if len(s_cpr) > 1 and unit:

                if level == 0:
                    iface = s_cpr[0]
                node_attrs['parent_id'] = self.id
                node_attrs['level'] = 2
                node_attrs['node_id'] = unit.id
                node_attrs['node_label'] = unit.id
            else:
                node_attrs['parent_id'] = parent_id
                node_attrs['level'] = 1
                node_attrs['node_id'] = self.id
                node_attrs['node_label'] = self.content['name']

            node_attrs['label'] = s_cpr[1] if len(s_cpr) > 1 else cpr

            if cpr in self.vlink_cp_refs:
                node_attrs['type'] = 'iface'
            elif cpr in self.vbridge_cp_refs:
                node_attrs['type'] = 'br-iface'

            graph.add_node(cpr, attr_dict=node_attrs)

        # build link topology graph
        for vl_id, vl in self.vlinks.items():

            edge_attrs = def_edge_attrs.copy()

            cpr_u = vl.cpr_u.split(':')
            cpr_v = vl.cpr_v.split(':')

            if level == 0:
                # unit interfaces not considered as nodes, just the unit itself
                if vl.cpr_u not in self.connection_points and len(cpr_u) > 1:
                    cpr_u = cpr_u[0]
                else:
                    cpr_u = vl.cpr_u

                if vl.cpr_v not in self.connection_points and len(cpr_v) > 1:
                    cpr_v = cpr_v[0]
                else:
                    cpr_v = vl.cpr_v

                edge_attrs['level'] = 1

            elif level == 1:
                # unit interfaces are nodes
                cpr_u = vl.cpr_u
                cpr_v = vl.cpr_v
                edge_attrs['level'] = 2

            edge_attrs['type'] = 'iface'
            edge_attrs['label'] = vl.id

            graph.add_edge(cpr_u, cpr_v, attr_dict=edge_attrs)

        if vdu_inner_connections:
            # link vdu interfaces if level 1
            if level == 1:
                for uid, unit in self.units.items():
                    edge_attrs = def_edge_attrs.copy()
                    join_cps = []
                    for cp in unit.connection_points:
                        # patch for faulty descriptors regarding sep ':'
                        s_cp = cp.split(':')
                        if len(s_cp) > 1:
                            join_cps.append(cp)
                        else:
                            join_cps.append(uid + ':' + cp)

                    for u_cp in join_cps:
                        for v_cp in join_cps:
                            if u_cp == v_cp:
                                continue
                            if graph.has_edge(u_cp, v_cp):
                                continue
                            if not bridges and (
                                    u_cp in self.vbridge_cp_refs or
                                    v_cp in self.vbridge_cp_refs):
                                continue
                            edge_attrs['level'] = 2
                            edge_attrs['label'] = 'VDU_IN'
                            edge_attrs['type'] = 'vdu_in'
                            graph.add_edge(u_cp, v_cp)

        # build bridge topology graph
        if bridges:
            for vb_id, vb in self.vbridges.items():
                # add bridge router
                brnode = "br-" + vb_id
                node_attrs = def_node_attrs.copy()
                node_attrs['label'] = brnode
                node_attrs['level'] = 2
                node_attrs['type'] = 'bridge'
                graph.add_node(brnode, attr_dict=node_attrs)

                for cpr in vb.connection_point_refs:
                    s_cpr = cpr.split(':')
                    if level == 0 and len(s_cpr) > 1:
                        s_cpr = s_cpr[0]
                    else:
                        s_cpr = cpr

                    graph.add_edge(brnode, s_cpr, attr_dict={'label': vb_id})
        return graph

    def undeclared_connection_points(self):
        """
        Provides a list of interfaces that are referenced in 'virtual_links'
        section but not declared in 'connection_points' of the Function and its
        Units.
        """
        target_cp_refs = self.vlink_cp_refs + self.vbridge_cp_refs

        undeclared_cps = []
        for cpr in target_cp_refs:
            cpr_split = cpr.split(':')
            if len(cpr_split) == 1 and cpr not in self.connection_points:
                undeclared_cps.append(cpr)
            elif len(cpr_split) == 2:
                if not cpr_split[0] in self.units:
                    undeclared_cps.append(cpr)
                else:
                    vdu = self.units[cpr_split[0]]
                    if cpr_split[1] not in vdu.connection_points:
                        undeclared_cps.append(cpr)

        return undeclared_cps


class Unit(Node):
    def __init__(self, uid):
        """
        Initialize a unit object. This inherits the node object.
        :param uid: unit id
        """
        self._id = uid
        super().__init__(self._id)

    @property
    def id(self):
        """
        Unit identifier
        :return: unit id
        """
        return self._id
