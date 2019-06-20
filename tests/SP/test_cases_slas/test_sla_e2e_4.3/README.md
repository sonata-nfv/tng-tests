### Test Case Descritpion

This SLA test case is supposed to check the **Private** license as a SLO.

**Private License:  ** 
The service is restricted by the need to buy the license for the corresponding NS:
1. When an instantiation request arrives to the GK, the GK validates through the SLA manager whether it needs to "buy" a license for that NS
1. If the validation is false (the service needs a license), then the GK again through the SLA manager "buys" the license and proceeds with the NS instantiation.