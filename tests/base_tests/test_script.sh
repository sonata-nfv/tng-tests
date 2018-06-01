#!/bin/bash

ENV_0=$1
echo $ENV_0

echo this is your selected environment:
echo "" > envfile.yml
echo

composed_env_path="../../environments/$ENV_0"

#checking the env file
ls $composed_env_path
#

cp -v $composed_env_path envfile.yml

#cat envfile.yml
mkdir ../../results/base_tests

ENV="envfile.yml"

echo This is the content of the env file:
cat envfile.yml
echo

pytest --junitxml=base_tests.xml



##deleting elements
#sed -i -- "s/environment_file/$ENV/g" delete_packages.yml
#echo
#echo
#result_delete=$(tavern-ci delete_packages.yml --stdout --debug)
#echo $result_delete
#echo "" > ../../results/packages/delete_results.log
#echo $result_delete >> ../../results/packages/delete_results.log
#echo
#sed -i -- "s/$ENV/environment_file/g" delete_packages.yml
#echo