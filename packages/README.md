# `packages/`

This folder contains a set of example packages used for the 5GTANGO integration tests.

The `*.tgo` packages files are not directly placed in this repo. Instead, the SDK project (containing the corresponding descriptors for each package) is placed in one subfolder inside `packages/`. The acutal packages (the `*.tgo` files) are automatically packed (on every commit) by Jenkins and are available [here](https://jenkins.sonata-nfv.eu/job/tng-tests/) (top of page).

Questions? Ask Manuel (@mpeuster).



## Service packages

| Name | Description |
+---+--------+
| NSID1C | A generic service package with one CNF |
| NSID1V | A generic service package with one VNF |
| NSID2C | A generic service package with two CNFs |
| NSID2V | A generic service package with two VNFs |
| NSID1V_cirros_OSM |  |
| NSID1V_cirros_OSM_cloud_init | |
| NSID1V_cirros_SONATA |  |
| NSIMPSP |  |
| NSINDP1C |  |
| NSTD | A hybrid package with NS and test |



## Test packages

| Name | Description |
+---+--------+
| TSTGNRPRB |  |
| TSTIMHLS |  |
| TSTIMPSP |  |
| TSTINDP |  |
| TSTPING |  |
| TSTPING_SONATA |  |
|  |  |
|  |  |
|  |  |
|  |  |

