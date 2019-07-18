#!/bin/bash

echo "show servers state" | socat stdio /var/run/hapee-lb.sock | while IFS= read -r line
do
  srv_op_state=$(echo "$line" | cut -d" " -f6)
  if [ $srv_op_state == 0 ]; then
    server_name=$(echo "$line" | cut -d" " -f4)
    echo "set server webservers/${server_name} addr $1" | socat stdio /var/run/hapee-lb.sock
    echo "set server webservers/${server_name} state ready" | socat stdio /var/run/hapee-lb.sock
    exit 0
  fi
done
if [[ $? -eq 0 ]]; then
    exit 0
else
    exit 1
fi

