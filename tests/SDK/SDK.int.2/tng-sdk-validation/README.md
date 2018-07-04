# tng-sdk-validation

<p align="center"><img src="https://github.com/sonata-nfv/tng-sdk-validation/wiki/images/sonata-5gtango-logo-500px.png" /></p>

This repository contains the `tng-sdk-validation` component that is part of the European H2020 project [5GTANGO](http://www.5gtango.eu) NFV SDK. This component can be used to validate the syntax, integrity and topology of 5GTANGO SDK packages, projects, services and functions. There is an additional feature to include custom rules in YAML files to validate the descriptors but it is still under development and not available in master.

`tng-sdk-validation` can be used through the CLI, as service  or as a micro-service running inside a docker container.

## Installation

This tool has been designed to be executed in Linux system and Python 3.6 or higher.

1. It is necessary to install [tng-sdk-project](https://github.com/sonata-nfv/tng-sdk-project) first as *tng-sdk-validation* depends on it. Please follow the instructions provided in the Readme file to install it.
 
2. Clone the master branch of this repository and access the directory.

3. Then install the Python dependencies.
```bash
$ pip3 install requirements.txt
```
4. The last step is to install *tng-sdk-validation*
```bash
$ python3 setup.py install
```
5. Once installed the command `tng-sdk-validate` should be available in your Linux system.

## Usage

### CLI mode

The CLI interface is designed for developer usage, allowing to quickly validate SDK projects,package descriptors, service descriptors and function descriptors. The different levels of validation, namely syntax, integrity and topology can only be used in the following combinations:

* syntax only: `-s`
* syntax and integrity `-si`
* syntax, integrity and topology `-sit`

The tng-sdk-validation CLI tool can be used to validate one of the following components:
`-project` - to validate an SDK project, the `--workspace` parameter must be specified, otherwise the default location `$ HOME/.tng-workspace` is assumed.

* package - to validate a package, only the `--package` should be specified indicating the path for the package file.
* service - in service validation, if the chosen level of validation comprises more than syntax (integrity or topology), the `--dpath` argument must be specified in order to indicate the location of the VNF descriptor files, referenced in the service. Has a standalone validation of a service, son-validate is not aware of a directory structure, unlike the project validation.
  Moreover, the `--dext` parameter should also be specified to indicate the extension of descriptor files.
* function - this specifies the validation of an individual VNF. It is also possible to validate multiple functions in bulk contained inside a directory. To if the `--function` is a directory, it will search for descriptor files with the extension specified by parameter `--dext`.

```
5gtango@validation-host:# tng-sdk-validate -h 
CLI input arguments: []
usage: tng-sdk-validate [-h] [-w WORKSPACE_PATH]
                        (--project PROJECT_PATH | --package PACKAGE_FILE | --service NSD | --function VNFD | --api)
                        [--dpath DPATH] [--dext DEXT] [--syntax] [--integrity]
                        [--topology] [--debug] [--mode {stateless,local}]
                        [--host SERVICE_ADDRESS] [--port SERVICE_PORT]
tng-sdk-validate: error: one of the arguments --project --package --service --function --api is required
root@debian-experiment:/home/quobis/tng-sdk-validation/src/tngsdk/validation/tests# tng-sdk-validate -h
CLI input arguments: ['-h']
usage: tng-sdk-validate [-h] [-w WORKSPACE_PATH]
                        (--project PROJECT_PATH | --package PACKAGE_FILE | --service NSD | --function VNFD | --api)
                        [--dpath DPATH] [--dext DEXT] [--syntax] [--integrity]
                        [--topology] [--debug] [--mode {stateless,local}]
                        [--host SERVICE_ADDRESS] [--port SERVICE_PORT]

5GTANGO SDK validator

optional arguments:
  -h, --help            show this help message and exit
  -w WORKSPACE_PATH, --workspace WORKSPACE_PATH
                        Specify the directory of the SDK workspace for
                        validating the SDK project.
  --project PROJECT_PATH
                        Validate the service of the specified SDK project.
  --package PACKAGE_FILE
                        Validate the specified package descriptor.
  --service NSD         Validate the specified service descriptor. The
                        directory of descriptors referenced in the service
                        descriptor should be specified using the argument '--
                        path'.
  --function VNFD       Validate the specified function descriptor. If a
                        directory is specified, it will search for descriptor
                        files with extension defined in '--dext'
  --api                 Run validator in service mode with REST API.
  --dpath DPATH         Specify a directory to search for descriptors.
                        Particularly useful when using the '--service'
                        argument.
  --dext DEXT           Specify the extension of descriptor files.
                        Particularly useful when using the '--function'
                        argument
  --syntax, -s          Perform a syntax validation.
  --integrity, -i       Perform an integrity validation.
  --topology, -t        Perform a network topology validation.
  --debug               Sets verbosity level to debug
  --mode {stateless,local}
                        Specify the mode of operation. 'stateless' mode will
                        run as a stateless service only. 'local' mode will run
                        as a service and will also provide automatic
                        monitoring and validation of local SDK projects,
                        services, etc. that are configured in the developer
                        workspace
  --host SERVICE_ADDRESS
                        Bind address for this service
  --port SERVICE_PORT   Bind port number

Example usage:
        tng-sdk-validate --project /home/sonata/projects/project_X
                     --workspace /home/sonata/.son-workspace
        tng-sdk-validate --service ./nsd_file.yml --path ./vnfds/ --dext yml
        tng-sdk-validate --function ./vnfd_file.yml
        tng-sdk-validate --function ./vnfds/ --dext yml
```

### Service mode
#### API overview

The API is an avolution of the API supported in the [Sonata-NFV *son-cli* project](https://github.com/sonata-nfv/son-cli).
A new synchronous feature has been added to the API. With this new feature it is possible to validate an object an receive the validation result in the reply of the HTTP POST request.
**Important:** Currently the descriptors files can not be passed as an attachement in the request but the file path is provided and must be accessible by the `tng-sdk-validate` executable. We plan to add the capability to pass the descriptor as an attachment in the POST request. 

#### Synchronous queries
In order to get a synchronous result the query string parameter `sync=true` must be added. This means that if the 200OK reply will contain the result of the validation process. If the sync parameter is not added or is false then the request is processed asynchronously. In any case the validation resource is created so its result can be checked at any moment.

#### Asynchronous queries (still not working in this version)
By default all the queries are asynchronous. It means that when a validation resource is created the API will reply inmediatly informaing about the result of the resource creation and the path to reach the validation resource not with the result not the validation itself. The validation result must be accessed later once the validation process has finished.

The end-points exposed by the API are as follows:

* validate an SDK project, a package, a service or a function (`/validate/<object type> [POST]`)
* retrieve a list of available and validated objects (`/report [GET]`)
* retrieve the validation report for a specific object (`/report/result/<resource id> [GET]`)
* retrieve the validated network topology graph (`/report/topology/<resource id> [GET]`)
* retrieve the validated forwarding graphs structure (`/fwgraphs/<resource id>) [GET]`)

## Documentation

TODO (e.g. link to wiki page)


## License

The tng-sdk-validation is published under Apache 2.0 license. Please see the LICENSE file for more details.

#### Lead Developers

The following lead developers are responsible for this repository and have admin rights. They can, for example, merge pull requests.

* Antón Román Portabales
* Ana Pol González

#### Feedback-Chanel

* You may use the mailing list [tango-5g-wp4@lists.atosresearch.eu](mailto:tango-5g-wp4@lists.atosresearch.eu)
* [GitHub issues](https://github.com/sonata-nfv/tng-sdk-validation/issues)
