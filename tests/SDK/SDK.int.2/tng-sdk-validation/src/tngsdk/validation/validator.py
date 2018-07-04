#  Copyright (c) 2018 SONATA-NFV, 5GTANGO, UBIWHERE, QUOBIS SL.
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
# Neither the name of the SONATA-NFV, 5GTANGO, UBIWHERE, QUOBIS 
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

#Python packages imports
import logging
import os
#from .event import *
import coloredlogs
import networkx as nx
import zipfile
import time
import shutil
import atexit
import errno
import yaml
import inspect

# Sonata and 55GTANGO imports
from tngsdk.project.workspace import Workspace
from tngsdk.project.project import Project

from tngsdk.validation.storage import DescriptorStorage
#from storage import DescriptorStorage
#from son.validate.util import read_descriptor_files, list_files, strip_root, build_descriptor_id
#from util import read_descriptor_files, list_files, strip_root, build_descriptor_id
from tngsdk.validation.util import read_descriptor_files, list_files, strip_root, build_descriptor_id
from tngsdk.validation.schema.validator import SchemaValidator
from tngsdk.validation import event

#LOG = logging.getLogger(os.path.basename(__file__))
log = logging.getLogger(__name__)
evtlog = event.get_logger('validator.events')


class Validator(object):
    def __init__(self, workspace=None):

        # by default all the tests are performed
        self._workspace = workspace
        self._syntax = True
        self._integrity = True
        self._topology = True

        # create "virtual" workspace if not provided (don't actually create
        # file structure)
        if not self._workspace:
            self._workspace = Workspace('.', log_level='info')

        # load configurations from workspace
        self._dext = self._workspace.default_descriptor_extension
        self._dpath = '.'
        self._log_level = self._workspace.log_level

        # # for package signature validation
        # self._pkg_signature = None
        # self._pkg_pubkey = None
        #
        # # configure logs
        # coloredlogs.install(level=self._log_level)

        # descriptors storage
        self._storage = DescriptorStorage()

        # syntax validation
        self._schema_validator = SchemaValidator(self._workspace, preload=True)

        # reset event logger
        evtlog.reset()

        # ANTON: what's this?
        self.source_id = None
        # forwarding graphs of the NS which is going to be validated
        self._fwgraphs = dict()

        pass

    @property
    def errors(self):
        return evtlog.errors

    @property
    def error_count(self):
        """
        Provides the number of errors given during validation.
        """
        return len(self.errors)

    @property
    def warnings(self):
        return evtlog.warnings

    @property
    def warning_count(self):
        """
        Provides the number of warnings given during validation.
        """
        return len(self.warnings)

    @property
    def storage(self):
        """
        Provides access to the stored resources during validation process.
        """
        return self._storage

    @property
    def dpath(self):
        return self._dpath

    @dpath.setter
    def dpath(self, value):
        self._dpath = value

    def configure(self, syntax=None, integrity=None, topology=None,
              dpath=None, dext=None, debug=None, pkg_signature=None,
              pkg_pubkey=None):
        """
        Configure parameters for validation. It is recommended to call this
        function before performing a validation.
        :param syntax: specifies whether to validate syntax
        :param integrity: specifies whether to validate integrity
        :param topology: specifies whether to validate network topology
        :param dpath: directory to search for function descriptors (VNFDs)
        :param dext: extension of descriptor files (default: 'yml')
        :param debug: increase verbosity level of logger
        ANTON do we have to validate the signatures of the packages??
        :param pkg_signature: String package signature to be validated
        :param pkg_pubkey: String package public key to verify signature
        """
        # assign parameters
        if syntax is not None:
            self._syntax = syntax
        if integrity is not None:
            self._integrity = integrity
        if topology is not None:
            self._topology = topology
        if dext is not None:
            self._dext = dext
        if dpath is not None:
            self._dpath = dpath
        if debug is True:
            self._workspace.log_level = 'debug'
            coloredlogs.install(level='debug')
        if debug is False:
            self._workspace.log_level = 'info'
            coloredlogs.install(level='info')
        if pkg_signature is not None:
            self._pkg_signature = pkg_signature
        if pkg_pubkey is not None:
            self._pkg_pubkey = pkg_pubkey

    def _assert_configuration(self):
        """
        Ensures that the current configuration is compatible with the
        validation to perform. If issues are found the application is
        interrupted with the appropriate error.
        This is an internal function which must be invoked only by:
        - 'validate_package'
        - 'validate_project'
        - 'validate_service'
        - 'validate_function'
        """
        # ensure this function is called by specific functions
        caller = inspect.stack()[1][3]
        if caller != 'validate_function' and caller != 'validate_service' and caller != 'validate_project' and caller != 'validate_package':
            log.error("Cannot assert a correct configuration. Validation scope couldn't be determined. Aborting")
            return

        # general rules - apply to all validations
        if self._integrity and not self._syntax:
            log.error("Cannot validate integrity without validating syntax first. Aborting.")
            return

        if self._topology and not self._integrity:
            log.error("Cannot validate topology without validating integrity first. Aborting.")
            return

        if not self._syntax:
            log.error("Nothing to validate. Aborting.")
            return

        if caller == 'validate_package':
            pass
        elif caller == 'validate_project':
            pass
        elif caller == 'validate_service':
            # check SERVICE validation parameters
            if (self._integrity or self._topology) and not (self._dpath and self._dext):
                log.error("Invalid validation parameters. To validate the "
                  "integrity or topology of a service both "
                  "'--dpath' and '--dext' parameters must be "
                  "specified.")
                return
        elif caller == 'validate_function':
            pass

        return True

    def validate_service(self, nsd_file):
        """
        Validate a 5GTANGO service.
        By default, it performs the following validations: syntax, integrity
        and network topology.
        :param nsd_file: service descriptor filename
        :return: True if all validations were successful, False otherwise
        """
        if not self._assert_configuration():
            return

        log.info("Validating service '{0}'".format(nsd_file))
        log.info("... syntax: {0}, integrity: {1}, topology: {2}"
                 .format(self._syntax, self._integrity, self._topology))
        service = self._storage.create_service(nsd_file)
        if not service:
            evtlog.log("Invalid service descriptor",
                       "Failed to read the service descriptor of file '{}'"
                       .format(nsd_file),
                       nsd_file,
                       'evt_service_invalid_descriptor')
            return

        # validate service syntax
        if self._syntax and not self._validate_service_syntax(service):
            return

        if self._integrity and not self._validate_service_integrity(service):
            return

        if self._topology and not self._validate_service_topology(service):
            return

        return True

    def _validate_service_topology(self, service):
        """
        Validate the network topology of a service.
        :return:
        """
        log.info("On working function")
        return
        log.info("Validating topology of service '{0}'".format(service.id))

        # build service topology graph with VNF connection points
        service.graph = service.build_topology_graph(level=1, bridges=False)
        if not service.graph:
            evtlog.log("Invalid topology",
                       "Couldn't build topology graph of service '{0}'"
                       .format(service.id),
                       service.id,
                       'evt_nsd_top_topgraph_failed')
            return

        log.debug("Built topology graph of service '{0}': {1}"
                  .format(service.id, service.graph.edges()))

        # write service graphs with different levels and options
        self.write_service_graphs(service)

        if nx.is_connected(service.graph):
            log.debug("Topology graph of service '{0}' is connected"
                      .format(service.id))
        else:
            evtlog.log("Disconnected topology",
                       "Topology graph of service '{0}' is disconnected"
                       .format(service.id),
                       service.id,
                       'evt_nsd_top_topgraph_disconnected')

        # check if forwarding graphs section is available
        if 'forwarding_graphs' not in service.content:
            evtlog.log("Forwarding graphs not available",
                       "No forwarding graphs available in service id='{0}'"
                       .format(service.id),
                       service.id,
                       'evt_nsd_top_fwgraph_unavailable')
            # don't enforce it (section not required)
            return True

        # load forwarding graphs
        if not service.load_forwarding_graphs():
            evtlog.log("Bad section: 'forwarding_graphs'",
                       "Couldn't load service forwarding graphs. ",
                       service.id,
                       'evt_nsd_top_badsection_fwgraph')
            return

        # analyse forwarding paths
        for fw_graph in service.fw_graphs:
            source_id = service.id + ":" + fw_graph['fg_id']

            for fw_path in fw_graph['fw_paths']:

                evtid = event.generate_evt_id()

                # check if number of connection points is odd
                if len(fw_path['path']) % 2 != 0:
                    evtlog.log("Odd number of connection points",
                               "The forwarding path fg_id='{0}', fp_id='{1}' "
                               "has an odd number of connection points".
                               format(fw_graph['fg_id'], fw_path['fp_id']),
                               source_id,
                               'evt_nsd_top_fwgraph_cpoints_odd',
                               event_id=evtid,
                               detail_event_id=fw_path['fp_id'])
                    fw_path['event_id'] = evtid

                fw_path['trace'] = service.trace_path_pairs(fw_path['path'])

                if any(pair['break'] is True for pair in fw_path['trace']):
                    evtlog.log("Invalid forwarding path ({0} breakpoint(s))"
                               .format(sum(pair['break'] is True
                                           for pair in fw_path['trace'])),
                               "fp_id='{0}':\n{1}"
                               .format(fw_path['fp_id'],
                                       yaml.dump(
                                           service.trace_path(
                                               fw_path['path']))),
                               source_id,
                               'evt_nsd_top_fwpath_invalid',
                               event_id=evtid,
                               detail_event_id=fw_path['fp_id'])
                    fw_path['event_id'] = evtid

                    # skip further analysis
                    return

                log.debug("Forwarding path fg_id='{0}', fp_id='{1}': {2}"
                          .format(fw_graph['fg_id'], fw_path['fp_id'],
                                  fw_path['trace']))

            # cycles must be analysed at the vnf level, not cp level.
            # here, a directed graph between vnfs must be created,
            # containing the cps of each node and edges between nodes.
            # Each edge must contain the pair of cps that links the
            # two nodes.
            # Having this structure is possible to find cycles between vnfs
            # and more importantly, identify which are the links
            #  (cp pair) that integrate a particular cycle.

            fpg = nx.DiGraph()
            for fw_path in fw_graph['fw_paths']:
                prev_node = None
                prev_iface = None
                pair_complete = False

                # convert 'connection point' path into vnf path
                for cp in fw_path['path']:
                    # find vnf_id of connection point
                    func = None
                    s_cp = cp.split(':')
                    if len(s_cp) == 2:
                        func = service.mapped_function(s_cp[0])
                        if not func:
                            log.error(
                                "Internal error: couldn't find corresponding"
                                " VNFs in forwarding path '{}'"
                                .format(fw_path['fp_id']))
                            return
                        node = service.vnf_id(func)

                    else:
                        node = cp
                        fpg.add_node(node)

                    if pair_complete:
                        if prev_node and prev_node == node:
                            evtid = event.generate_evt_id()
                            evtlog.log("Path within the same VNF",
                                       "The forwarding path fg_id='{0}', "
                                       "fp_id='{1}' contains a path within the"
                                       " same VNF id='{2}'"
                                       .format(fw_graph['fg_id'],
                                               fw_path['fp_id'],
                                               node),
                                       source_id,
                                       'evt_nsd_top_fwpath_inside_vnf',
                                       event_id=evtid,
                                       detail_event_id=fw_path['fp_id'])
                            fw_path['event_id'] = evtid

                            # reset trace
                            fw_path['trace'] = []
                            continue

                        fpg.add_edge(prev_node, node,
                                     attr_dict={'from': prev_iface,
                                                'to': cp})
                        pair_complete = False

                    else:
                        if prev_node and prev_node != node:
                            evtlog.log("Disrupted forwarding path",
                                       "The forwarding path fg_id='{0}', "
                                       "fp_id='{1}' is disrupted at the "
                                       "connection point: '{2}'"
                                       .format(fw_graph['fg_id'],
                                               fw_path['fp_id'],
                                               cp),
                                       source_id,
                                       'evt_nsd_top_fwpath_disrupted',
                                       event_id=source_id)

                        pair_complete = True

                    prev_node = node
                    prev_iface = cp

                # remove 'path' from fw_path (not needed anymore)
                fw_path.pop('path')

            # find cycles
            complete_cycles = list(nx.simple_cycles(fpg))

            # remove 1-hop cycles
            cycles = []
            for cycle in complete_cycles:
                if len(cycle) > 2:
                    cycles.append(cycle)

            # build cycles representative connection point structure
            cycles_list = []
            for cycle in cycles:
                cycle_dict = {'cycle_id': str(uuid.uuid4()), 'cycle_path': []}

                for idx, node in enumerate(cycle):
                    link = {}

                    if idx+1 == len(cycle):  # at last element
                        next_node = cycle[0]
                    else:
                        next_node = cycle[idx+1]

                    neighbours = fpg.neighbors(node)
                    if next_node not in neighbours:
                        log.error("Internal error: couldn't find next hop "
                                  "when building structure of cycle: {}"
                                  .format(cycle))
                        continue

                    edge_data = fpg.get_edge_data(node, next_node)
                    link['from'] = edge_data['from']
                    link['to'] = edge_data['to']

                    cycle_dict['cycle_path'].append(link)
                cycles_list.append(cycle_dict)

            # report cycles
            if cycles_list and len(cycles_list) > 0:
                evtid = event.generate_evt_id()
                for cycle in cycles_list:
                    evtlog.log("Found {0} cycle(s) (fg_id='{1}')"
                               .format(len(cycles_list), fw_graph['fg_id']),
                               "{0}"
                               .format(yaml.dump(cycle['cycle_path'],
                                       default_flow_style=False)),
                               source_id,
                               'evt_nsd_top_fwgraph_cycles',
                               event_id=evtid,
                               detail_event_id=cycle['cycle_id'])
                fw_graph['cycles'] = cycles_list
                fw_graph['event_id'] = evtid

        return True

    @staticmethod
    def write_service_graphs(service):
        graphsdir = 'graphs'
        try:
            os.makedirs(graphsdir)
        except OSError as exc:
            if exc.errno == errno.EEXIST and os.path.isdir(graphsdir):
                pass

        service.build_topology_graph(level=3, bridges=False)

        for lvl in range(0, 4):
            g = service.build_topology_graph(level=lvl, bridges=False)
            nx.write_graphml(g, os.path.join(graphsdir,
                                             "{0}-lvl{1}.graphml"
                                             .format(service.id, lvl)))
            g = service.build_topology_graph(level=lvl, bridges=True)
            nx.write_graphml(g, os.path.join(graphsdir,
                                             "{0}-lvl{1}-br.graphml"
                                             .format(service.id, lvl)))

        g = service.build_topology_graph(level=3, bridges=True,
                                         vdu_inner_connections=False)
        service.complete_graph = nx.generate_graphml(g, encoding='utf-8',
                                                     prettyprint=True)
        nx.write_graphml(g, os.path.join(graphsdir,
                                         "{0}-lvl3-complete.graphml"
                                         .format(service.id)))

    def _validate_service_syntax(self, service):
        """
        Validate a the syntax of a service (NS) against its schema.
        :param service: service to validate
        :return: True if syntax is correct, None otherwise
        """
        log.info("Validating syntax of service '{0}'".format(service.id))
        if not self._schema_validator.validate(
              service.content, SchemaValidator.SCHEMA_SERVICE_DESCRIPTOR):
            evtlog.log("Invalid NSD syntax",
                       "Invalid syntax in service '{0}': {1}"
                       .format(service.id, self._schema_validator.error_msg),
                       service.id,
                       'evt_nsd_stx_invalid')
            return
        return True

    def _validate_service_integrity(self, service):
        """
        Validate the integrity of a service (NS).
        It checks for inconsistencies in the identifiers of connection
        points, virtual links, etc.
        :param service: service to validate
        :return: True if integrity is correct
        :param service:
        :return:
        """

        log.info("Validating integrity of service '{0}'".format(service.id))


        # get referenced function descriptors (VNFDs)
        if not self._load_service_functions(service):
            evtlog.log("Function not available",
                       "Failed to read service function descriptors",
                       service.id,
                       'evt_nsd_itg_function_unavailable')
            return

        # validate service function descriptors (VNFDs)
        for fid, f in service.functions.items():
            if not self.validate_function(f.filename):
                evtlog.log("Invalid function",
                           "Failed to validate function descriptor '{0}'"
                           .format(f.filename),
                           service.id,
                           'evt_nsd_itg_function_invalid')
                return

        # load service connection points
        if not service.load_connection_points():
            evtlog.log("Bad section 'connection_points'",
                       "Couldn't load the connection points of "
                       "service id='{0}'"
                       .format(service.id),
                       service.id,
                       'evt_nsd_itg_badsection_cpoints')
            return

        # load service links
        if not service.load_virtual_links():
            evtlog.log("Bad section 'virtual_links'",
                       "Couldn't load virtual links of service id='{0}'"
                       .format(service.id),
                       service.id,
                       'evt_nsd_itg_badsection_vlinks')
            return

        undeclared = service.undeclared_connection_points()
        if undeclared:
            for cxpoint in undeclared:
                evtlog.log("{0} Undeclared connection point(s)"
                           .format(len(undeclared)),
                           "Virtual links section has undeclared connection "
                           "point: {0}".format(cxpoint),
                           service.id,
                           'evt_nsd_itg_undeclared_cpoint')
            return

        # check for unused connection points
        unused_ifaces = service.unused_connection_points()
        if unused_ifaces:
            for cxpoint in unused_ifaces:
                evtlog.log("{0} Unused connection point(s)"
                           .format(len(unused_ifaces)),
                           "Unused connection point: {0}"
                           .format(cxpoint),
                           service.id,
                           'evt_nsd_itg_unused_cpoint')

        # verify integrity between vnf_ids and vlinks
        for vl_id, vl in service.vlinks.items():
            for cpr in vl.connection_point_refs:
                s_cpr = cpr.split(':')
                if len(s_cpr) == 1 and cpr not in service.connection_points:
                    evtlog.log("Undefined connection point",
                               "Connection point '{0}' in virtual link "
                               "'{1}' is not defined"
                               .format(cpr, vl_id),
                               service.id,
                               'evt_nsd_itg_undefined_cpoint')
                    return
                elif len(s_cpr) == 2:
                    func = service.mapped_function(s_cpr[0])
                    if not func or s_cpr[1] not in func.connection_points:
                        evtlog.log("Undefined connection point",
                                   "Function (VNF) of vnf_id='{0}' declared "
                                   "in connection point '{0}' in virtual link "
                                   "'{1}' is not defined"
                                   .format(s_cpr[0], s_cpr[1], vl_id),
                                   service.id,
                                   'evt_nsd_itg_undefined_cpoint')
                        return
        return True

    def _load_service_functions(self, service):
        """
        Loads and stores functions (VNFs) referenced in the specified service
        :param service: service
        :return: True if successful, None otherwise
        """

        log.debug("Loading functions of the service.")
        # # get VNFD file list from provided dpath
        if not self._dpath:
            return
        vnfd_files = list_files(self._dpath, self._dext)
        log.debug("Found {0} descriptors in dpath='{2}': {1}"
                  .format(len(vnfd_files), vnfd_files, self._dpath))

        # load all VNFDs
        path_vnfs = read_descriptor_files(vnfd_files)

        # check for errors
        if 'network_functions' not in service.content:
            log.error("Service doesn't have any functions. "
                      "Missing 'network_functions' section.")
            return

        functions = service.content['network_functions']
        if functions and not path_vnfs:
            evtlog.log("VNF not found",
                       "Service references VNFs but none could be found in "
                       "'{0}'. Please specify another '--dpath'"
                       .format(self._dpath),
                       service.id,
                       'evt_nsd_itg_function_unavailable')
            return

        # store function descriptors referenced in the service
        for func in functions:
            fid = build_descriptor_id(func['vnf_vendor'],
                                      func['vnf_name'],
                                      func['vnf_version'])
            if fid not in path_vnfs.keys():
                evtlog.log("VNF not found",
                           "Referenced function descriptor id='{0}' couldn't "
                           "be loaded".format(fid),
                           service.id,
                           'evt_nsd_itg_function_unavailable')
                return

            vnf_id = func['vnf_id']
            new_func = self._storage.create_function(path_vnfs[fid])

            service.associate_function(new_func, vnf_id)

        return True

    def validate_function(self, vnfd_path):
        """
        Validate one or multiple 5GTANGO functions (VNFs).
        By default, it performs the following validations: syntax, integrity
        and network topology.
        :param vnfd_path: function descriptor (VNFD) filename or
                          a directory to search for VNFDs
        :return: True if all validations were successful, False otherwise
        """
        #if not self._assert_configuration():
        #    return

        # validate multiple VNFs
        if os.path.isdir(vnfd_path):
            log.info("Validating functions in path '{0}'".format(vnfd_path))
            vnfd_files = list_files(vnfd_path, self._dext)
            #ANTON
            print(*vnfd_files, sep='\n')
            for vnfd_file in vnfd_files:
                log.info("Detected file {0} order validation...".format(vnfd_file))
                if not self.validate_function(vnfd_file):
                    return
            return True

        log.info("Validating function '{0}'".format(vnfd_path))
        log.info("... syntax: {0}, integrity: {1}, topology: {2}"
                 .format(self._syntax, self._integrity, self._topology))

        func = self._storage.create_function(vnfd_path)
        if not func:
            evtlog.log("Invalid function descriptor",
                       "Couldn't store VNF of file '{0}'".format(vnfd_path),
                       vnfd_path,
                       'evt_function_invalid_descriptor')
            return

        if self._syntax and not self._validate_function_syntax(func):
            return True

        if self._integrity and not self._validate_function_integrity(func):
            return True

        if self._topology and not self._validate_function_topology(func):
            return True

        return True

    def _validate_function_syntax(self, func):
        """
        Validate the syntax of a function (VNF) against its schema.
        :param func: function to validate
        :return: True if syntax is correct, None otherwise
        """
        log.info("Validating syntax of function '{0}'".format(func.id))
        if not self._schema_validator.validate(
                func.content, SchemaValidator.SCHEMA_FUNCTION_DESCRIPTOR):
            evtlog.log("Invalid VNFD syntax",
                       "Invalid syntax in function '{0}': {1}"
                       .format(func.id, self._schema_validator.error_msg),
                       func.id,
                       'evt_vnfd_stx_invalid')
            return
        return True

    def _validate_function_integrity(self, func):
        """
        Validate the integrity of a function (VNF).
        It checks for inconsistencies in the identifiers of connection
        points, virtual deployment units (VDUs), ...
        :param func: function to validate
        :return: True if integrity is correct
        """
        log.info("Validating integrity of function descriptor '{0}'"
                 .format(func.id))

        # load function connection points
        if not func.load_connection_points():
            evtlog.log("Missing 'connection_points'",
                       "Couldn't load the connection points of "
                       "function id='{0}'"
                       .format(func.id),
                       func.id,
                       'evt_vnfd_itg_badsection_cpoints')
            return

        # load units
        if not func.load_units():
            evtlog.log("Missing 'virtual_deployment_units'",
                       "Couldn't load the units of function id='{0}'"
                       .format(func.id),
                       func.id,
                       'evt_vnfd_itg_badsection_vdus')
            return

        # load connection points of units
        if not func.load_unit_connection_points():
            evtlog.log("Bad section 'connection_points'",
                       "Couldn't load VDU connection points of "
                       "function id='{0}'"
                       .format(func.id),
                       func.id,
                       'evt_vnfd_itg_vdu_badsection_cpoints')
            return

        # load function links
        if not func.load_virtual_links():
            evtlog.log("Bad section 'virtual_links'",
                       "Couldn't load the links of function id='{0}'"
                       .format(func.id),
                       func.id,
                       'evt_vnfd_itg_badsection_vlinks')
            return

        # check for undeclared connection points
        undeclared = func.undeclared_connection_points()
        if undeclared:
            for cxpoint in undeclared:
                evtlog.log("{0} Undeclared connection point(s)"
                           .format(len(undeclared)),
                           "Virtual links section has undeclared connection "
                           "points: {0}".format(cxpoint),
                           func.id,
                           'evt_vnfd_itg_undeclared_cpoint')
            return

        # check for unused connection points
        unused_ifaces = func.unused_connection_points()
        if unused_ifaces:
            for cxpoint in unused_ifaces:
                evtlog.log("{0} Unused connection point(s)"
                           .format(len(unused_ifaces)),
                           "Function has unused connection points: {0}"
                           .format(cxpoint),
                           func.id,
                           'evt_vnfd_itg_unused_cpoint')

        # verify integrity between unit connection points and units
        for vl_id, vl in func.vlinks.items():
            for cpr in vl.connection_point_refs:
                s_cpr = cpr.split(':')
                if len(s_cpr) == 1 and cpr not in func.connection_points:
                    evtlog.log("Undefined connection point",
                               "Connection point '{0}' in virtual link "
                               "'{1}' is not defined"
                               .format(cpr, vl_id),
                               func.id,
                               'evt_nsd_itg_undefined_cpoint')
                    return
                elif len(s_cpr) == 2:
                    unit = func.units[s_cpr[0]]
                    if not unit or s_cpr[1] not in unit.connection_points:

                        evtlog.log("Undefined connection point(s)",
                                   "Invalid connection point id='{0}' "
                                   "of virtual link id='{1}': Unit id='{2}' "
                                   "is not defined"
                                   .format(s_cpr[1], vl_id, s_cpr[0]),
                                   func.id,
                                   'evt_vnfd_itg_undefined_cpoint')
                        return
        return True

    def _validate_function_topology(self, func):
        """
        Validate the network topology of a function.
        It builds the topology graph of the function, including VDU
        connections.
        :param func: function to validate
        :return: True if topology doesn't present issues
        """
        log.info("Validating topology of function '{0}'"
                 .format(func.id))

        # build function topology graph
        func.graph = func.build_topology_graph(bridges=True)
        if not func.graph:
            evtlog.log("Invalid topology graph",
                       "Couldn't build topology graph of function '{0}'"
                       .format(func.id),
                       func.id,
                       'evt_vnfd_top_topgraph_failed')
            return

        log.debug("Built topology graph of function '{0}': {1}"
                  .format(func.id, func.graph.edges()))
        log.info("Built topology graph of function '{0}': {1}"
                  .format(func.id, func.graph.edges()))

        return True

    def workspace(self):
        log.warning("workspace not implemented")
