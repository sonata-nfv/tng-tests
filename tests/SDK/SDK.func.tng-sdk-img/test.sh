#!/bin/bash

DIR=$PWD

image_name="functest_tng-sdk-img"
instance_name="functest_tng-sdk-img"
key_name="functest_tng-sdk-img"
private_key=`tempfile`
flavor_name="test"
secgroup_name="ssh-secgroup"
internal_network_name="net1"
management_network_name="mgmt"
ssh_config=`tempfile`
floating_ip=""
vnf_ifs=("internal", "management")

export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=tango.qual
export OS_PASSWORD=t4ng0.qual
export OS_AUTH_URL=http://10.100.33.2:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

function build_docker() {
  echo "Building Docker image"
  docker build -t simplehttp_vnf .
  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
}

function install_converter() {
  echo "Installing the converter"
  git clone https://github.com/sonata-nfv/tng-sdk-img
  cd tng-sdk-img
  bash install.sh
  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
  cd ..
  rm -rf tng-sdk-img
}

function convert() {
  echo "Converting an image"
  tng-sdk-img convert simplehttp_vnfd.yml
  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
}
function upload_image() {
  echo "Uploading an image"
  
  glance image-create --name $image_name --disk-format=qcow2 --container-format=bare --file=./simplehttp-vnf_1.qcow2

  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
}

function create_server() {
  echo "Creating a server $instance_name"

  image_id=`openstack image show $image_name -f value -c id 2>/dev/null`
  flavor_id=`openstack flavor show $flavor_name -f value -c id 2>/dev/null`
  network_id=`openstack network show $network_name -f value -c id 2>/dev/null`

  
  openstack server create --flavor $flavor_id --image $image_id --key-name $key_name --security-group $secgroup_name --network $network_id $instance_name

  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
}

function delete_server() {
  echo "Deleting the server $instance_name"
  openstack server delete $instance_name
  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
}

function create_key() {
  echo "Creating key $key_name and saving private key in $private_key"
  openstack keypair create $key_name > $private_key
  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
}

function delete_key() {
  echo "Deleting key $key_name and private key $private_key"
  openstack keypair delete $key_name
  rm $private_key
  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
}

function wait_server() {
  echo -n "Waiting until instance ($instance_name) is active" 
  local instance_status=`openstack server show $instance_name -f value -c status` 
  while [[ $instance_status != "ACTIVE" ]]; do 
    echo -n "." 
    sleep 1 
    instance_status=`openstack server show $instance_name -f value -c status` 
  done 
  echo "OK" 
} 

function wait_ssh() {
  echo -n "Waiting until instance's ssh comes up"
  while ! nc -z $floating_ip 22; do
    echo -n "."
    sleep 1
  done
  echo "OK"
}

function create_ssh_config() {
  cat << EOF > $ssh_config
Host $instance_name
  Hostname $floating_ip
  User ubuntu
  IdentityFile $private_key
  IdentitiesOnly yes
  StrictHostKeyChecking no
EOF
}

function add_floating_ip() {
  echo "Looking for available floating IP"
  floating_ip=`openstack floating ip list -f value -c Port -c "Floating IP Address" | awk '$2=="None"{print $1; exit}'    `
  if [[ -n $floating_ip ]]; then
    echo "Found: $floating_ip"
  else
    echo "Not found, creating one"
    floating_ip=`openstack floating ip create public -f value -c floating_ip_address`
    echo "Created $floating_ip"
  fi
  echo "Adding floating IP $floating_ip_address"
  local instance_id=`openstack server show $instance_name -f value -c id`
  openstack server add floating ip $instance_id $floating_ip
  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
}

function delete_ssh_config() {
  rm $ssh_config
}

function c_ssh() {
  ssh -q -F $ssh_config $instance_name $@
}

function c_scp() {
  scp -q -F $ssh_config $1 $instance_name:$2
}

function set_up() {
  buiid_docker
  install_converter
  convert
  upload_image
  create_key
  create_server
  wait_server
  add_floating_ip
  wait_ssh
  create_ssh_config
}

function tear_down() {
  delete_key
  delete_server
  delete_ssh_config
}

function check_ssh() {
  c_ssh true
  if [[ $? -eq 0 ]]; then
    echo "Ok"
  else
    echo "Failed"
    exit 1
  fi
}

function check_interfaces() {
  echo "Checking interfaces"
  server_ifs=`c_ssh ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d'`
  server_ifs=`echo $server_ifs | xargs -n1 | sort`
  vnf_ifs=`echo $vnf_ifs | xargs -n1 | sort`

  for i in "${vnf_ifs[@]}"; do
    echo "Checking $i"
    ip=`ifconfig $i | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
    if [[ $? -eq 0 ]]; then
      if [[-n $ip ]]; then
        echo "ok"
      else
        echo "Failed"
        exit 1
      fi
    else
      echo "Failed"
      exit 1
    fi
  done
}

function check_docker() {
  docker_status=`c_ssh docker ps | grep "vnf-container"`
  if [[ $? -eq 0 ]]; then
    if [[-n $docker_status ]]; then
      echo "ok"
    else
      echo "Failed"
      exit 1
    fi
  else
    echo "Failed"
    exit 1
  fi
}

function check_service() {
  response=`curl $floating_ip`
  if [[ $? -eq 0 ]]; then
    if [[ $response == "passed" ]]; then
      echo "ok"
    else
      echo "Failed"
      exit 1
    fi
  else
    echo "Failed"
    exit 1
  fi
}

set_up
check_interfaces
check_docker
check_service
tear_down
