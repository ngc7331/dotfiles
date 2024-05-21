#!/bin/bash

set -e

IPV6=${IPV6:-true}
NAME=${NAME:-colorful-br}

echo colorful: creating docker network ${NAME}
if [ "$IPV6" == "true" ]; then
  extra_args="--ipv6 --subnet fd21::/80 --gateway fd21::1"

  if [ ! -f /etc/docker/daemon.json ]; then
    echo colorful: creating /etc/docker/daemon.json
    cat << EOF >> /etc/docker/daemon.json
{
  "ipv6": true,
  "fixed-cidr-v6": "fc00::/80",
  "experimental": true,
  "ip6tables": true
}
EOF
    systemctl daemon-reload
    systemctl restart docker
  else
    echo colorful: /etc/docker/daemon.json already exists
  fi
fi

if docker network inspect ${NAME} &>/dev/null; then
  echo colorful: network ${NAME} already exists
else
  docker network create --subnet 172.21.0.0/16 --gateway 172.21.0.1 ${extra_args} ${NAME}
fi
