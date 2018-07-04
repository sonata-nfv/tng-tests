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

from setuptools import setup, find_packages


setup(name='tng-project',
      license='Apache License, Version 2.0',
      version='0.9',
      url='https://github.com/sonata-nfv/tng-sdk-project',
      author='Manuel Peuster',
      author_email='manuel.peuster@uni-paderborn.de',
      package_dir={'': 'src'},
      packages=find_packages('src'),   # dependency resolution
      include_package_data=True,       # package data specified in MANIFEST.in
      install_requires=['PyYAML', 'pytest', 'pyaml', 'oyaml', 'coloredlogs', 'tabulate'],
      zip_safe=False,
      entry_points={
          'console_scripts': [
              'tng-sdk-workspace=tngsdk.project.workspace:init_workspace',
              'tng-workspace=tngsdk.project.workspace:init_workspace',
              'tng-wks=tngsdk.project.workspace:init_workspace',
              'tng-sdk-project=tngsdk.project.project:create_project',
              'tng-project=tngsdk.project.project:create_project',
              'tng-prj=tngsdk.project.project:create_project',
              'tng-sdk-descriptorgen=tngsdk.descriptorgen.descriptorgen:'
              'generate',
              'tng-descriptorgen=tngsdk.descriptorgen.descriptorgen:generate',
              'tng-dgn=tngsdk.descriptorgen.descriptorgen:generate'
          ],
      },
      test_suite='tngsdk',
      tests_require=['pytest'])
