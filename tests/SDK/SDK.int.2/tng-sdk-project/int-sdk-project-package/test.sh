#!/bin/bash
set -e

# create a workspace
printf "Configuring workspace"
tng-workspace

# create a project
printf "Creating project"
tng-project -p p1

# create and add a text file
printf "Create and add test file"
echo "test text file" > p1/test.txt
tng-project -p p1 --add p1/test.txt

# package the project (currently fails since packaging is not yet implemented)
printf "Package the project"
tng-package -p p1

# TODO: check created package

