# `packages/`

This folder contains a set of example packages used for the 5GTANGO integration tests.

The `*.tgo` packages files are not directly placed in this repo. Instead, the SDK project (containing the corresponding descriptors for each package) is placed in one subfolder inside `packages/`. The acutal packages (the `*.tgo` files) are automatically packed (on every commit) by Jenkins and are available [here](https://jenkins.sonata-nfv.eu/job/tng-tests-freestyle/) (top of page).

Questions? Ask Manuel (@mpeuster).

