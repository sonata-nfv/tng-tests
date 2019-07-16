# `packages/`

This folder contains a set of example packages used for the 5GTANGO integration tests.

The `*.tgo` packages files are not directly placed in this repo. Instead, the SDK project (containing the corresponding descriptors for each package) is placed in one subfolder inside `packages/`. The acutal packages (the `*.tgo` files) are automatically packed (on every commit) by Jenkins and are available [here](https://jenkins.sonata-nfv.eu/job/tng-tests/) (top of page).

Questions? Ask Manuel (@mpeuster).



## Service packages

| Name | Description |
|---|---|
| NSID1C | A generic service package with one CNF |
| NSID1V | A generic service package with one VNF |
| NSID2C | A generic service package with two CNFs |
| NSID2V | A generic service package with two VNFs |
| NSID1V_cirros_OSM | A generic service package with a simple cirros VNF for OSM |
| NSID1V_cirros_OSM_cloud_init |A generic service package for OSM with one VNF that has cloud-init |
| NSID1V_cirros_SONATA | A generic service package with a simple cirros VNF for Sonata |
| NSID1V_osm_charms | A generic service package for OSM with one VNF that has JUJU charms |
| NSID1V_hybrid | Hybrid package containing a service and a test for Sonata |
| NSIMPSP |  |
| NSINDP1C |  |
| NSTD | A generic network slice template composed by 3 NSs (all of them are nsid1v) |
| ns-squid-haproxy | This NS provides a flexible and high available proxy service, by combining the opensource HAProxy load balancer with a pool of squid backend servers.|




## Test packages

| Name | Description |
|---|---|
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

