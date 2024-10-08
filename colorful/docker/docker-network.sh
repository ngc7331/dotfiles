#!/bin/bash

set -e
source $(dirname $0)/../utils.sh

NAME=${NAME:-colorful-br}
SUBNET=${SUBNET:-21}

if [ "$(docker network inspect ${NAME} 2>/dev/null)" != "[]" ]; then
  info "Network ${NAME} already exists"
else
  info "Creating network ${NAME}"
  docker network create \
    --subnet 172.${SUBNET}.0.0/16 --gateway 172.${SUBNET}.0.1 \
    --ipv6 --subnet fd${SUBNET}::/80 --gateway fd${SUBNET}::1 \
    -o com.docker.network.bridge.name=${NAME} \
    ${NAME}
fi
