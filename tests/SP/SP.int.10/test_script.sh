#!/bin/bash
#
ENV_0=$1
echo $ENV_0
#
echo this is your selected environment:
echo "" > envfile.yml
echo

composed_env_path="../../../environments/$ENV_0"

#checking the env file
ls "$composed_env_path"
#

cp -v "$composed_env_path" envfile.yml

#cat envfile.yml
mkdir ../../../results/sp.10

ENV="envfile.yml"

echo This is the content of the env file:
cat envfile.yml
echo


#echo
echo "running pytest"
######
py.test --junitxml=../../../results/sp.10/sp.10.xml
######
#tavern-ci test_00.get_services-functions.tavern.yml --stdout --debug
######


#echo
echo sp_10_script_finished
