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



##changing env info in tests
sed -i -- "s/environment_file/$ENV/g" test.01.get_packages.tavern.yml
sed -i -- "s/environment_file/$ENV/g" test.02.get_admin_logs.tavern.yml
echo
cat test.01.get_packages.tavern.yml
echo 
#echo
#echo
pytest --junitxml=../../results/base_tests/base_tests.xml


#echo
#sed -i -- "s/$ENV/environment_file/g" test.01.get_packages.tavern.yml
#sed -i -- "s/$ENV/environment_file/g" test.02.get_admin_logs.tavern.yml
#echo