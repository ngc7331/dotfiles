#!/bin/bash

IPV6=${IPV6:-true}

echo colorful: creating docker network br
if [ "$IPV6" == "true" ]; then
  extra_args="--ipv6 --subnet fd21::/80 --gateway fd21::1"
fi
docker network create --subnet 172.21.0.0/16 --gateway 172.21.0.1 ${extra_args} br
