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
mkdir ../../../../results/sp.14

ENV="envfile.yml"

echo This is the content of the env file:
cat envfile.yml
echo


#echo
echo "running pytest"
cd ..
pytest Scale_a_service.py --junitxml=../../../results/sp.14.xml --tb=short


#echo
echo sp_14_script_finished
