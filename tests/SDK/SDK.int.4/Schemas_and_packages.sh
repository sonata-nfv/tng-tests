#!/bin/bash
###SDK 4

git clone https://github.com/sonata-nfv/tng-schema.git
cd tng-schema/package-specification/example-projects
tng-pkg -p 5gtango-ns-project-example
tng-pkg -p 5gtango-test-project-example