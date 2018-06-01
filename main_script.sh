#!/bin/bash
#
ENV=$1

echo "This is the environment file you have select:"
echo $ENV

cd tests/base_tests/
VAR=$(sh test_script.sh ''$ENV'')
echo $VAR

echo "Main script finished"
##
#
