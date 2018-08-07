#!/bin/bash
#
ENV_0=$1
echo $ENV_0
#
echo this is your selected environment:
echo "" > envfile.yml
echo

composed_env_path="../../../../environments/$ENV_0"

#checking the env file
ls "$composed_env_path"
#

cp -v "$composed_env_path" envfile.yml
cp -v envfile.yml ..

#cat envfile.yml
mkdir ../../../../results/sp.1

ENV="envfile.yml"

echo This is the content of the env file:
cat envfile.yml
echo


#echo
echo "running pytest"
cd ..
pytest Valid_package_is_stored.py --junitxml=../../../results/sp.1.xml --tb=short
######
#py.test --junitxml=../../../results/sp.1.xml --tb=short
######
#tavern-ci test_00.get_packages.tavern.yml --stdout --debug
######
#tavern-ci test_01.upload_package.tavern.yml --stdout --debug

#echo
echo sp_1_script_finished
