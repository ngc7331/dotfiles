#!/bin/bash
MIRROR=${MIRROR:-docker.io/}
VERSION=${VERSION:-latest}

DIST=${DIST:-agent}

fail() {
  echo colorful: $@
  exit 1
}

if [ "$DIST" == "agent" ]; then
  echo colorful: installing portainer-agent
  docker pull "$MIRROR"portainer/agent:"$VERSION" || fail Pull failed
  docker stop portainer_agent
  docker rm portainer_agent
  docker run -d \
    --name portainer_agent \
    --restart=always \
    --network=br \
    -p 9001:9001 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    "$MIRROR"portainer/agent:"$VERSION"
elif [ "$DIST" == "ce" ] || [ "$DIST" == "ee" ]; then
  echo colorful: installing portainer-"$DIST"
  docker pull "$MIRROR"portainer/portainer-"$DIST":"$VERSION" || fail Pull failed
  docker stop portainer
  docker rm portainer
  docker run -d \
    --name portainer \
    --restart=always \
    --network=br \
    -p 8000:8000 \
    -p 9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    "$MIRROR"portainer/portainer-"$DIST":"$VERSION"
else
  fail Invalid DIST="$DIST", select from "[agent, ce, ee]"
fi
