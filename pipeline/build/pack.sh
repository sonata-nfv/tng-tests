#!/bin/bash
set -e
source venv_sdk/bin/activate
which tng-project
which tng-validate
which tng-package
BASE_DIR="$(pwd)"
cd packages/
# trigger package script
./pack.sh
cd $BASE_DIR