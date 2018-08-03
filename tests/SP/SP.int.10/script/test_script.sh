#!/bin/bash
#
ENV_0=$1
echo $ENV_0
#
echo this is your selected environment:
echo "" > envfile.yml
echo

composed_env_path="../envfile.yml"

#checking the env file
ls "$composed_env_path"
#

cp -v "$composed_env_path" envfile.yml
cp -v envfile.yml ..

cat envfile.yml
mkdir ../../../../results/sp.10

ENV="envfile.yml"

echo This is the content of the env file:
cat envfile.yml
echo


#echo
echo "running pytest"
cd ..
pytest Terminate_a_service.py --junitxml=../../../results/sp.10.xml --tb=short


#echo
echo sp_10_script_finished
