<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

### Test Case Descritpion

This test case is testing the integration between the Recommendation Engine and the Gatekeeper. When a new test Package is uploaded, the Gatekeeper
informs the recommendation engine which is responsible to extract the testing tags and the username from the package's metadata and update the recommendations.

**Steps:**
1. Create a user
1. Log in user
1. Add Token to Header 
1. Upload a test package (testing tags included in Package Descriptor)
1. Retrieve user from rec_engine
1. Delete the User from Recommendation Engine
1. Delete the User from User Management
1. Delete the Package
1. Obtain and store the Logs 