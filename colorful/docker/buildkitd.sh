#!/bin/bash

set -e
source $(dirname $0)/../utils.sh

DOCKERDIR=$(realpath ~/.docker)
CONFDIR=${DOCKERDIR}/buildkit
CERTDIR=${CONFDIR}/.certs
SAN=${SAN:-"localhost 127.0.0.1 ::1"}
EXTRA_ARGS=${EXTRA_ARGS:-}

if [ ! -f "${CERTDIR}/daemon/ca.pem" ]; then
  info "Creating certs"
  mkdir -p ${DOCKERDIR} ${CONFDIR} ${CERTDIR}
  # https://docs.docker.com/build/builders/drivers/remote/#example-remote-buildkit-in-docker-container
  cd ${CONFDIR}
  SAN=${SAN} docker buildx bake "https://github.com/moby/buildkit.git#master:examples/create-certs"
  cd -
fi

info "Creating buildkitd container"
docker stop buildkitd && docker rm buildkitd && info "Old container removed" || info "Fresh install"
docker run -d \
  --restart=unless-stopped \
  --name=buildkitd \
  --privileged \
  -p 1234:1234/tcp \
  -v ${CERTDIR}:/etc/buildkit/certs \
  ${EXTRA_ARGS} \
  moby/buildkit:latest \
  --addr tcp://0.0.0.0:1234 \
  --tlscacert /etc/buildkit/certs/daemon/ca.pem \
  --tlscert /etc/buildkit/certs/daemon/cert.pem \
  --tlskey /etc/buildkit/certs/daemon/key.pem
