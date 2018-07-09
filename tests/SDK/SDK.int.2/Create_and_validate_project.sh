#!/bin/bash
###SDK 2

tng-workspace


tng-sdk-project -p test_project

tng-sdk-validate --service test_project/sources/nsd/nsd-sample.yml