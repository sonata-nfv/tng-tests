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

import sys
import os
import logging
import oyaml as yaml        # ordered yaml to avoid reordering of descriptors
import shutil
import pkg_resources
import glob
import mimetypes
import argparse
import coloredlogs
from collections import defaultdict
from tabulate import tabulate
from tngsdk.project.workspace import Workspace


log = logging.getLogger(__name__)


class Project:

    BACK_CONFIG_VERSION = "0.4"
    CONFIG_VERSION = "0.5"

    __descriptor_name__ = 'project.yml'

    def __init__(self, workspace, prj_root, config=None):
        self._prj_root = prj_root
        self._workspace = workspace
        if config:
            self._prj_config = config
        else:
            self.load_default_config()

        # get config from workspace for URL->MIME mapping
        with open(workspace.config["projects_config"], 'r') as config_file:
            self.type_mapping = yaml.load(config_file)

    @property
    def project_root(self):
        return self._prj_root

    @property
    def nsd_root(self):
        return os.path.join(self._prj_root, 'sources', 'nsd')

    @property
    def vnfd_root(self):
        return os.path.join(self._prj_root, 'sources', 'vnf')

    @property
    def project_config(self):
        return self._prj_config

    @property
    def descriptor_extension(self):
        return self.project_config['descriptor_extension']

    def load_default_config(self):
        self._prj_config = {
            'version': self.CONFIG_VERSION,
            'package': {
                'name': '5gtango-project-sample',
                'vendor': 'eu.5gtango',
                'version': '0.1',
                'maintainer': 'Name, Company, Contact',
                'description': 'Some description about this sample'
            },
            'descriptor_extension':
                self._workspace.default_descriptor_extension,
            'files': []
        }

    def create_prj(self):
        log.info('Creating project at {}'.format(self._prj_root))

        self._create_dirs()
        self._write_prj_yml()

    def _create_dirs(self):
        """
        Creates the directory tree of the project
        :return:
        """
        directories = {'sources', 'dependencies', 'deployment'}
        src_subdirs = {'vnfd', 'nsd'}

        # Check if dir exists
        if os.path.isdir(self._prj_root):
            print("Unable to create project at '{}'. "
                  "Directory already exists."
                  .format(self._prj_root), file=sys.stderr)
            exit(1)

        os.makedirs(self._prj_root, exist_ok=False)
        for d in directories:
            path = os.path.join(self._prj_root, d)
            os.makedirs(path, exist_ok=True)

        src_path = os.path.join(self._prj_root, 'sources')
        vnfd_path = os.path.join(src_path, 'vnfd')
        nsd_path = os.path.join(src_path, 'nsd')
        os.makedirs(vnfd_path, exist_ok=True)
        os.makedirs(nsd_path, exist_ok=True)
        self._create_vnfd(vnfd_path)
        self._create_nsd(nsd_path)

    # create directory and sample VNFD
    def _create_vnfd(self, path):
        sample_vnfd = 'vnfd-sample.yml'
        vnfd_path = os.path.join(path, sample_vnfd)
        rp = __name__

        # Copy sample VNF descriptor
        src_path = os.path.join('samples', sample_vnfd)
        srcfile = pkg_resources.resource_filename(rp, src_path)
        shutil.copyfile(srcfile, vnfd_path)
        self.add_file(vnfd_path)

    # create NSD
    def _create_nsd(self, path):
        sample_nsd = 'nsd-sample.yml'
        nsd_path = os.path.join(path, sample_nsd)
        rp = __name__

        # Copy sample NS descriptor
        src_path = os.path.join('samples', sample_nsd)
        srcfile = pkg_resources.resource_filename(rp, src_path)
        shutil.copyfile(srcfile, nsd_path)
        self.add_file(nsd_path)

    # writes project descriptor to file (project.yml)
    def _write_prj_yml(self):
        prj_path = os.path.join(self._prj_root, Project.__descriptor_name__)
        with open(prj_path, 'w') as prj_file:
            prj_file.write(yaml.dump(self._prj_config,
                                     default_flow_style=False))

    # resolves wildcards by calling add/remove_file for each file
    def resolve_wildcards(self, path, add=False, remove=False):
        for f in glob.glob(path):
            if add:
                self.add_file(f)
            if remove:
                self.remove_file(f)

    # detects and returns MIME type of specified file
    def mime_type(self, file):
        name, extension = os.path.splitext(file)

        # check yml files to detect and classify 5GTANGO descriptors
        if extension == ".yml" or extension == ".yaml":
            with open(file, 'r') as yml_file:
                yml_file = yaml.load(yml_file)
                if 'descriptor_schema' in yml_file:
                    type = self.type_mapping[yml_file['descriptor_schema']]
                else:
                    log.warning('Could not detect MIME type of {}. '
                                'Using text/yaml'.format(file))
                    type = 'text/yaml'

        # for non-yml files determine the type using mimetypes
        else:
            (type, encoding) = mimetypes.guess_type(file, strict=False)
            # add more types from a config with mimetypes.read_mime_types(file)

        log.debug('Detected MIME type: {}'.format(type))
        return type

    # adds a file to the project: detects type and adds to project.yml
    def add_file(self, file_path, type=None):
        # resolve wildcards
        if '*' in file_path:
            log.debug('Attempting to resolve wildcard in {}'.format(file_path))
            self.resolve_wildcards(file_path, add=True)
            return

        # try to detect the MIME type if none is given
        if type is None:
            type = self.mime_type(file_path)
        if type is None:
            log.error('Could not detect MIME type of {}. Please specify using'
                      'the -t argument.'.format(file_path))
            return

        # calculate relative file path to project root
        abs_file_path = os.path.abspath(file_path)
        abs_prj_root = os.path.abspath(self._prj_root)
        rel_file_path = os.path.relpath(abs_file_path, abs_prj_root)

        # add to project.yml
        file = {'path': rel_file_path, 'type': type, 'tags': ['eu.5gtango']}
        if file in self._prj_config['files']:
            log.warning('{} is already in project.yml.'.format(file_path))
        else:
            self._prj_config['files'].append(file)
            self._write_prj_yml()
            log.info('Added {} to project.yml'.format(file_path))

    # removes a file from the project
    def remove_file(self, file_path):
        # resolve wildcards
        if '*' in file_path:
            log.debug('Attempting to resolve wildcard in {}'.format(file_path))
            self.resolve_wildcards(file_path, remove=True)
            return

        # calculate relative file path to project root (similar to add_file)
        abs_file_path = os.path.abspath(file_path)
        abs_prj_root = os.path.abspath(self._prj_root)
        rel_file_path = os.path.relpath(abs_file_path, abs_prj_root)

        for f in self._prj_config['files']:
            if f['path'] == rel_file_path:
                self._prj_config['files'].remove(f)
                self._write_prj_yml()
                log.info('Removed {} from project.yml'.format(file_path))
                return
        log.warning('{} is not in project.yml'.format(file_path))

    # prints project info/status
    def project_status(self):
        # print general info
        print('Project: {}'.format(self._prj_config['package']['name']))
        print('Vendor: {}'.format(self._prj_config['package']['vendor']))
        print('Version: {}'.format(self._prj_config['package']['version']))
        print(self._prj_config['package']['description'])

        if 'files' not in self._prj_config:
            log.warning('Old SONATA project: project.yml does not have a files section!'
                        'To translate an old SONATA project to a new 5GTANGO project, use --translate')
            return

        # collect and print info about involved MIME types (type + quanity)
        types = defaultdict(int)
        for f in self._prj_config['files']:
            types[f['type']] += 1
        print(tabulate(types.items(), ['MIME type', 'Quantity'], 'grid'))

    # translate old SONATA VNFD or NSD to new 5GTANGO format (descriptor_version --> descriptor_schema)
    def translate_descriptor(self, descriptor_file, vnfd):
        log.info('Translating descriptor {}'.format(descriptor_file))
        with open(descriptor_file, 'r') as f:
            descriptor = yaml.load(f)

        descriptor.pop('descriptor_version')
        if vnfd:
            schema = self.type_mapping['application/vnd.5gtango.vnfd']
        else:
            schema = self.type_mapping['application/vnd.5gtango.nsd']
        descriptor['descriptor_schema'] = schema

        with open(descriptor_file, 'w') as f:
            f.write(yaml.dump(descriptor, default_flow_style=False))

    # translate old SONATA project to new 5GTANGO project (in place)
    def translate(self):
        log.debug('Attempting to translate old SONATA project to new 5GTANGO '
                  'project (in place): {}'.format(self._prj_root))

        # update/set version number to current version
        log.debug('Updating version number to {}'.format(self.CONFIG_VERSION))
        self._prj_config['version'] = self.CONFIG_VERSION

        # update descriptors: replace "schema_version" with "descriptor_schema" based on nsd/vnf folder
        log.debug('Updating old SONATA descriptors to new 5GTANGO descriptors')
        vnfd_path = os.path.join(self._prj_root, 'sources', 'vnf', '**', '*.yml')
        for vnfd in glob.glob(vnfd_path, recursive=True):
            if os.path.isfile(vnfd):
                self.translate_descriptor(vnfd, vnfd=True)
        nsd_path = os.path.join(self._prj_root, 'sources', 'nsd', '**', '*.yml')
        for nsd in glob.glob(nsd_path, recursive=True):
            if os.path.isfile(nsd):
                self.translate_descriptor(nsd, vnfd=False)

        # create files section and add files
        log.debug('Creating "files" section and adding all files in {}'.format(self._prj_root))
        self._prj_config['files'] = []
        for f in glob.glob(os.path.join(self._prj_root, 'sources', '**'), recursive=True):
            if os.path.isfile(f):
                self.add_file(f)

        self._write_prj_yml()
        log.info('Successfully translated {} to 5GTANGO project.'.format(self._prj_root))

    @staticmethod
    def __is_valid__(project):
        """Checks if a given project is valid"""
        if type(project) is not Project:
            return False

        if not os.path.isfile(os.path.join(
                project.project_root,
                Project.__descriptor_name__)):
            return False

        return True

    @staticmethod
    def __create_from_descriptor__(workspace, prj_root, translate=False):
        """
        Creates a Project object based on a configuration descriptor
        :param prj_root: base path of the project
        :return: Project object
        """
        prj_filename = os.path.join(prj_root, Project.__descriptor_name__)
        if not os.path.isdir(prj_root) or not os.path.isfile(prj_filename):
            log.error("Unable to load project descriptor '{}'".format(prj_filename))
            return None

        log.info("Loading Project configuration '{}'".format(prj_filename))

        with open(prj_filename, 'r') as prj_file:
            try:
                prj_config = yaml.load(prj_file)

            except yaml.YAMLError as exc:
                log.error("Error parsing descriptor file: {0}".format(exc))
                return

            if not prj_config:
                log.error("Couldn't read descriptor file: '{0}'".format(prj_file))
                return

        if prj_config['version'] == Project.CONFIG_VERSION:
            return Project(workspace, prj_root, config=prj_config)

        # Protect against invalid versions
        if prj_config['version'] < Project.BACK_CONFIG_VERSION and not translate:
            log.error("Project configuration version '{0}' is no longer supported (<{1})."
                      "To translate to new 5GTANGO project version use --translate"
                      .format(prj_config['version'], Project.CONFIG_VERSION))
            return
        if prj_config['version'] > Project.CONFIG_VERSION and not translate:
            log.error("Project configuration version '{0}' is ahead of the current supported version (={1})."
                      "To translate to new 5GTANGO project version use --translate"
                      .format(prj_config['version'], Project.CONFIG_VERSION))
            return

        # Make adjustments to support backwards compatibility
        # 0.4
        if prj_config['version'] == "0.4":

            prj_config['package'] = {'name': prj_config['name'],
                                     'vendor': prj_config['vendor'],
                                     'version': '0.1',
                                     'maintainer': prj_config['maintainer'],
                                     'description': prj_config['description']
                                     }
            prj_config.pop('name')
            prj_config.pop('vendor')
            prj_config.pop('maintainer')
            prj_config.pop('description')
            log.warning("Loading project with an old configuration "
                        "version ({0}). Modified project configuration: {1}"
                        .format(prj_config['version'], prj_config))

        return Project(workspace, prj_root, config=prj_config)


def parse_args_project():
    parser = argparse.ArgumentParser(description="Create new 5GTANGO project")
    parser.add_argument("-p", "--project",
                        help="create a new project at the specified location",
                        required=True)

    parser.add_argument("-w", "--workspace",
                        help="location of existing (or new) workspace. "
                        "If not specified will assume '{}'"
                        .format(Workspace.DEFAULT_WORKSPACE_DIR),
                        required=False)

    parser.add_argument("--debug",
                        help="increases logging level to debug",
                        required=False,
                        action="store_true")

    parser.add_argument("--add",
                        help="Add file to project",
                        required=False,
                        default=None)

    parser.add_argument("-t", "--type",
                        help="MIME type of added file (only with --add)",
                        required=False,
                        default=None)

    parser.add_argument("--remove",
                        help="Remove file from project",
                        required=False,
                        default=None)

    parser.add_argument("--status",
                        help="Show project file paths",
                        required=False,
                        action="store_true")

    parser.add_argument("--translate",
                        help="Translate old SONATA project to new 5GTANGO project",
                        required=False,
                        action="store_true")

    return parser, parser.parse_args()


def create_project():
    parser, args = parse_args_project()

    if args.debug:
        coloredlogs.install(level='DEBUG')
    else:
        coloredlogs.install(level='INFO')

    # use specified workspace or default
    if args.workspace:
        ws_root = os.path.expanduser(args.workspace)
    else:
        ws_root = Workspace.DEFAULT_WORKSPACE_DIR

    ws = Workspace.__create_from_descriptor__(ws_root)
    if not ws:
        print("Could not find a 5GTANGO workspace at the specified location",
              file=sys.stderr)
        exit(1)

    prj_root = os.path.expanduser(args.project)

    if args.add:
        # load project and add file to project.yml
        log.debug("Attempting to add file {}".format(args.add))
        proj = Project.__create_from_descriptor__(ws, prj_root)
        proj.add_file(args.add, type=args.type)

    elif args.remove:
        # load project and remove file from project.yml
        log.debug("Attempting to remove file {}".format(args.remove))
        proj = Project.__create_from_descriptor__(ws, prj_root)
        proj.remove_file(args.remove)

    elif args.status:
        # load project and show status
        log.debug("Attempting to show project status")
        proj = Project.__create_from_descriptor__(ws, prj_root)
        proj.project_status()

    elif args.translate:
        proj = Project.__create_from_descriptor__(ws, prj_root, translate=True)
        proj.translate()

    else:
        # create project
        log.debug("Attempting to create a new project")
        proj = Project(ws, prj_root)
        proj.create_prj()
        log.debug("Project created.")


if __name__ == '__main__':
    create_project()
