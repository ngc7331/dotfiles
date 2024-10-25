#!/bin/bash

set -e
source $(dirname $0)/../utils.sh

MIRROR=${MIRROR:-docker.io}
VERSION=${VERSION:-latest}
SERVER=${SERVER:-localhost}
BUILDKITD_EXTRA_ARGS=${BUILDKITD_EXTRA_ARGS:-}

dotenv $(dirname $0)/.env.buildkitd

DOCKERDIR=$(realpath ~/.docker)
CONFDIR=${DOCKERDIR}/buildkit
CERTDIR=${CONFDIR}/.certs
SAN=${SAN:-"${SERVER} 127.0.0.1 ::1"}
if [ "${SERVER}" != "localhost" ]; then
  SAN="${SAN} localhost"
fi

info "Installing buildkitd"
info "MIRROR=${MIRROR}"
info "VERSION=${VERSION}"
info "SERVER=${SERVER}"
info "BUILDKITD_EXTRA_ARGS=${BUILDKITD_EXTRA_ARGS}"
debug "DOCKERDIR=${DOCKERDIR}"
debug "CONFDIR=${CONFDIR}"
debug "CERTDIR=${CERTDIR}"
debug "SAN=${SAN}"

if [ ! -f "${CERTDIR}/daemon/ca.pem" ]; then
  info "Creating certs"
  mkdir -p "${DOCKERDIR}" "${CONFDIR}" "${CERTDIR}"
  # https://docs.docker.com/build/builders/drivers/remote/#example-remote-buildkit-in-docker-container
  cd "${CONFDIR}"
  SAN="${SAN}" docker buildx bake "https://github.com/moby/buildkit.git#master:examples/create-certs"
  cd -
fi

info "Creating buildkitd container"
docker stop buildkitd && docker rm buildkitd && info "Old container removed" || info "Fresh install"
docker run -d \
  --restart=unless-stopped \
  --name=buildkitd \
  --privileged \
  -p 1234:1234/tcp \
  -v "${CERTDIR}":/etc/buildkit/certs \
  ${BUILDKITD_EXTRA_ARGS} \
  "${MIRROR}/moby/buildkit:${VERSION}" \
  --addr tcp://0.0.0.0:1234 \
  --tlscacert /etc/buildkit/certs/daemon/ca.pem \
  --tlscert /etc/buildkit/certs/daemon/cert.pem \
  --tlskey /etc/buildkit/certs/daemon/key.pem
