[![Join the chat at https://gitter.im/5gtango/tango-sdk](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/5gtango/tango-sdk)

<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

# tng-sdk-project

This repository contains the `tng-sdk-project` component that is part of the European H2020 project [5GTANGO](http://www.5gtango.eu) NFV SDK. This component is responsible to manage network service workspaces and projects on the developer's machine.

The seed code of this component is based on the `son-cli` toolbox that was developed as part of the European H2020 project [SONATA](http://sonata-nfv.eu).

## Installation

```bash
$ python setup.py install
```

Requires Python 3.5+

## Usage

To start working, you need a workspace that holds your configuration files. The default location is `~/.tng-workspace/`, but it may be at any location and there can also be multiple workspaces.

```bash
$ tng-workspace       # initializes a new workspace at the default location
$ tng-workspace --workspace path/to/workspace     # inits a workspace at a custom location
```

Once you have a workspace, you can create projects with the `tng-project` command.
You can also add or remove files from the project (wildcards allowed) or check the project status.

```bash
$ tng-project -p path/to/project                # creates a new project at the specified path
$ tng-project -p path/to/project --add file1    # adds file1 to the project.yml
$ tng-project -p path/to/project --add file1 --type text/plain  # adds file1 with explicit MIME type
$ tng-project -p path/to/project --remove file1 # removes file1 from the project.yml
$ tng-project -p path/to/project --status       # shows project overview/status
```

The `--workspace` option allows to specify a workspace at a custom location. Otherwise, the workspace at the default location is used.
For both `tng-workspace` and `tng-project` the option `--debug` makes the output more verbose.

Since the structure of projects and descriptors changed from SONATA (v3.1) to 5GTANGO (v4.0), `tng-project` also provides a command to automatically translate old to new projects.
For more information see the [corresponding wiki page](https://github.com/sonata-nfv/tng-sdk-project/wiki/Translating-SONATA-SDK-projects-to-5GTAGNO-SDK-projects).

```bash
$ tng-project -p path/to/old-project --translate   # translates the project to the new structure
```

## Documentation

See the [wiki](https://github.com/sonata-nfv/tng-sdk-project/wiki) for further documentation and details.

## Development

To contribute to the development of this 5GTANGO component, you may use the very same development workflow as for any other 5GTANGO Github project. That is, you have to fork the repository and create pull requests.

### Setup development environment

```bash
$ python setup.py develop
```

### CI Integration

All pull requests are automatically tested by Jenkins and will only be accepted if no test is broken.

### Run tests manually

You can also run the test manually on your local machine. To do so, you need to do:

```bash
$ pytest -v
$ pycodestyle .
```

## License

This 5GTANGO component is published under Apache 2.0 license. Please see the LICENSE file for more details.

---
#### Lead Developers

The following lead developers are responsible for this repository and have admin rights. They can, for example, merge pull requests.

- Manuel Peuster ([@mpeuster](https://github.com/mpeuster))
- Stefan Schneider ([@StefanUPB](https://github.com/StefanUPB))

#### Feedback-Chanel

* Please use the GitHub issues to report bugs.
