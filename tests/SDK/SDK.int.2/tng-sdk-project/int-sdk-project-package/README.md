# Integration test tng-sdk-project and tng-sdk-package

Test if generated projects can be packaged correctly.

The Dockerfile can be used to create a Docker container with project and package installed. `test.sh` contains the steps for the integration test.

This integration test should be moved to a separate repository, e.g., tng-int-test, once it exists. Then, `test.sh` should be integrated with Jenkins.
