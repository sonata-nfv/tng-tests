[![Build Status](https://jenkins.sonata-nfv.eu/buildStatus/icon?job=tng-api-gtw/master)](https://jenkins.sonata-nfv.eu/job/tng-api-gtw/master)
[![Join the chat at https://gitter.im/5gtango/tango-schema](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/5gtango/5gtango-sp)

<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

# 5GTANGO API Integration Tests
This is the 5GTANGO API Integration Tests for the Verification&amp;Validation, Service Platforms and SDK

Please see [details on the overall 5GTANGO architecture here](https://5gtango.eu/project-outcomes/deliverables/2-uncategorised/31-d2-2-architecture-design.html). 

## How does this work?

For testing the we are using two different ways. Somes tests are created using bash scripts and other are created using the pytest plugin tavern (https://taverntesting.github.io/).

Also you can select the enviroment in which you want to test the components.

For further details on these components, please check those component's README files.

Other components are the following:

* [tng-common](https://github.com/sonata-nfv/tng-gtk-common/);
* [tng-gtk-sp](https://github.com/sonata-nfv/tng-gtk-sp);
* [tng-gtk-vnv](https://github.com/sonata-nfv/tng-gtk-vnv);
* [tng-policy-mngr](https://github.com/sonata-nfv/tng-policy-mngr);
* [tng-sla-mgmt](https://github.com/sonata-nfv/tng-sla-mgmt);
* [tng-slice-mngr](https://github.com/sonata-nfv/tng-slice-mngr);

## Developing

You can fork this repository, add your test and after the pull request they will be included in the Jenkins automated task.
