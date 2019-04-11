[![Join the chat at https://gitter.im/sonata-nfv/Lobby](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/sonata-nfv/Lobby) 

<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

# 5GTANGO Integration Tests

This repository contains the integration tests as well as artifacts for the 5GTANGO components.

## Folder Structure

| Folder | Content |
| --- | --- |
|`pipeline/`| Jenkins pipeline scripts | - |
|`packages/`| Test NSDs, VNFDs, TSTDs to be packed to `*.tgo` packages |
|`slas/`|Examples of SLA Descriptors |
|`tests/`| Integration tests classified by SDK/SP/VnV |
|...|...|

## Artifacts

* [5GTANGO packages (`*.tgo`) build by Jenkins](https://jenkins.sonata-nfv.eu/view/PIPELINE/job/tng-tests/job/master/)

## Jenkins Integration

There is a Jenkins job to automatically build some of the artifacts stored in this repositry. For example, the Jenkins job automatically packages the SDK projects available in the `packages/` folder. The resulting `*.tgo` files are then available as [artifacts within Jenkins](https://jenkins.sonata-nfv.eu/view/PIPELINE/job/tng-tests/job/master/).

## Licensing

For licensing issues, please check the [Licence](https://github.com/sonata-nfv/tng-tests/blob/master/LICENSE) file.

#### Lead Developers

The following lead developers are responsible for this repository and have admin rights. They can, for example, merge pull requests.

* Felipe Vicens (felipevicens)
* Luis Hens (luishens01)
