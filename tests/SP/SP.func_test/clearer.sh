#!/bin/bash

echo "cleaning slas"
tavern-ci clear_slas.yml --stdout --debug
echo
echo "cleaning policies"
tavern-ci clear_policies.yml --stdout --debug
echo
echo "cleaning packages"
tavern-ci clear_packages.yml --stdout --debug
echo 
echo "clear finished"