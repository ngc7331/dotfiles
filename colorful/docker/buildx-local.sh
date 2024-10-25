#!/bin/bash

set -e
source $(dirname $0)/../utils.sh

SERVER=${SERVER:-localhost}
BUILDER_NAME=${BUILDER_NAME:-local}

dotenv $(dirname $0)/.env.buildx

DOCKERDIR=$(realpath ~/.docker)
CONFDIR=${DOCKERDIR}/buildkit
CERTDIR=${CONFDIR}/.certs

info "Installing buildx local builder"
info "SERVER=${SERVER}"
info "BUILDER_NAME=${BUILDER_NAME}"
debug "DOCKERDIR=${DOCKERDIR}"
debug "CONFDIR=${CONFDIR}"
debug "CERTDIR=${CERTDIR}"

info "Creating buildx builder"
docker buildx create \
  --name "${BUILDER_NAME}" \
  --driver remote \
  --driver-opt cacert="${CERTDIR}/client/ca.pem,cert=${CERTDIR}/client/cert.pem,key=${CERTDIR}/client/key.pem,servername=${SERVER}" \
  "tcp://${SERVER}:1234"

info "Setting ${NAME} builder as default"
docker buildx use "${NAME}"
