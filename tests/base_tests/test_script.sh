#!/bin/bash

ENV_0=$1
echo $ENV_0

echo this is your selected environment:
echo "" > envfile.yml
echo

composed_env_path="../../environments/$ENV_0"

#checking the env file
ls "$composed_env_path"
#

cp -v "$composed_env_path" envfile.yml

#cat envfile.yml
mkdir ../../results/base_tests

ENV="envfile.yml"

echo This is the content of the env file:
cat envfile.yml
echo

#pytest --junitxml=base_tests.xml
echo "updating pytest"
sudo pip install -U pytest

#echo
echo "running pytest"
pytest --junitxml=../../results/base_tests/base_tests.xml

#echo
echo base_tests_script_finished