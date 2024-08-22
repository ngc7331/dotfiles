#!/bin/bash

set -e
source $(dirname $0)/../utils.sh

DOCKERDIR=$(realpath ~/.docker)
CONFDIR=${DOCKERDIR}/buildkit
CERTDIR=${CONFDIR}/.certs
SERVER=${SERVER:-localhost}
NAME=${NAME:-local}

info "Creating buildx builder"
docker buildx create \
  --name ${NAME} \
  --driver remote \
  --driver-opt cacert=${CERTDIR}/client/ca.pem,cert=${CERTDIR}/client/cert.pem,key=${CERTDIR}/client/key.pem,servername=${SERVER} \
  tcp://${SERVER}:1234

info "Setting ${NAME} builder as default"
docker buildx use ${NAME}
