#!/bin/bash

set -e
source $(dirname $0)/../utils.sh

DIST=${DIST:-agent}
MIRROR=${MIRROR:-docker.io}
VERSION=${VERSION:-latest}
NETWORK=${NETWORK:-colorful-br}
PORTAINER_EXTRA_ARGS=${PORTAINER_EXTRA_ARGS:-}

dotenv $(dirname $0)/.env.portainer

info "Installing portainer"
info "DIST=${DIST}"
info "MIRROR=${MIRROR}"
info "VERSION=${VERSION}"
info "NETWORK=${NETWORK}"

if [ "${DIST}" == "agent" ]; then
  docker pull "${MIRROR}/portainer/agent:${VERSION}" || fatal "Pull failed"
  docker stop portainer_agent && docker rm portainer_agent && info "Old container removed" || info "Fresh install"
  docker run -d \
    --name portainer_agent \
    --restart=always \
    --network=${NETWORK} \
    -p 9001:9001 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    ${PORTAINER_EXTRA_ARGS} \
    "${MIRROR}/portainer/agent:${VERSION}"
elif [ "${DIST}" == "ce" ] || [ "${DIST}" == "ee" ]; then
  docker pull "${MIRROR}/portainer/portainer-${DIST}:${VERSION}" || fatal "Pull failed"
  docker stop portainer && docker rm portainer && info "Old container removed" || info "Fresh install"
  docker run -d \
    --name portainer \
    --restart=always \
    --network="${NETWORK}" \
    -p 8000:8000 \
    -p 9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    ${PORTAINER_EXTRA_ARGS} \
    "${MIRROR}/portainer/portainer-${DIST}:${VERSION}"
else
  fatal "Invalid DIST=${DIST}, select from [agent, ce, ee]"
fi
