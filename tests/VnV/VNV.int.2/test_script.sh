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
mkdir ../../../results/vnv.2

ENV="envfile.yml"

echo This is the content of the env file:
cat envfile.yml
echo


#echo
echo "running pytest"
######
#py.test --junitxml=../../../results/vnv.2/vnv.2.xml
######
tavern-ci test.01.uploadTsr.tavern.yml --stdout --debug
######


#echo
echo sp_1_script_finished
