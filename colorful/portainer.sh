#!/bin/bash

set -e
source utils.sh

MIRROR=${MIRROR:-docker.io/}
VERSION=${VERSION:-latest}
NETWORK=${NETWORK:-colorful-br}

DIST=${DIST:-agent}

if [ "$DIST" == "agent" ]; then
  info "Installing portainer-agent"
  docker pull "$MIRROR"portainer/agent:"$VERSION" || fatal "Pull failed"
  docker stop portainer_agent
  docker rm portainer_agent
  docker run -d \
    --name portainer_agent \
    --restart=always \
    --network=${NETWORK} \
    -p 9001:9001 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    "$MIRROR"portainer/agent:"$VERSION"
elif [ "$DIST" == "ce" ] || [ "$DIST" == "ee" ]; then
  info "Installing portainer-$DIST"
  docker pull "$MIRROR"portainer/portainer-"$DIST":"$VERSION" || fatal "Pull failed"
  docker stop portainer
  docker rm portainer
  docker run -d \
    --name portainer \
    --restart=always \
    --network=${NETWORK} \
    -p 8000:8000 \
    -p 9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    "$MIRROR"portainer/portainer-"$DIST":"$VERSION"
else
  fatal "Invalid DIST=$DIST, select from [agent, ce, ee]"
fi
