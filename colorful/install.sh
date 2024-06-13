#!/bin/bash

set -e
source utils.sh

ENABLE_SSH=${ENABLE_SSH:-true}
ENABLE_FAIL2BAN=${ENABLE_FAIL2BAN:-true}
ENABLE_DOCKER=${ENABLE_DOCKER:-false}
ENABLE_TAILSCALE=${ENABLE_TAILSCALE:-false}
USER=${USER:-}

PACKAGES=(ca-certificates curl)
SERVICES=()
CONFIG_FILES=()
if [ "$ENABLE_SSH" = "true" ]; then
  PACKAGES+=(openssh-server)
  SERVICES+=(ssh)
  CONFIG_FILES+=(/etc/ssh/sshd_config.d/00-colorful.conf)
fi
if [ "$ENABLE_FAIL2BAN" = "true" ]; then
  PACKAGES+=(fail2ban)
  SERVICES+=(fail2ban)
  CONFIG_FILES+=(/etc/fail2ban/jail.d/00-colorful.conf)
fi
if [ "$ENABLE_DOCKER" = "true" ]; then
  # use a standalone
  SERVICES+=(docker)
  CONFIG_FILES+=(/etc/docker/daemon.json)
fi

# stages
create_user() {
  if [ ! -z "$(cat /etc/passwd | grep ${USER})" ]; then
    info "User ${USER} already exists"
    return
  fi
  info "Creating user: ${USER}"
  adduser ${USER}
}

add_user_group() {
  info "Adding user to sudo group"
  usermod -aG sudo ${USER}
  if [ ! -z "$(cat /etc/group | grep docker)" ]; then
    info "Adding user to docker group"
    usermod -aG docker ${USER}
  fi
}

install_packages() {
  info "Installing packages: ${PACKAGES[@]}"
  apt update
  apt install -y ${PACKAGES[@]}

  if [ "$ENABLE_DOCKER" = "true" ]; then
    # Borrowed from https://docs.docker.com/engine/install/ubuntu/
    # Add Docker's official GPG key:
    if [ ! -f /etc/apt/keyrings/docker.asc ]; then
      info "Adding Docker's official GPG key"
      install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      chmod a+r /etc/apt/keyrings/docker.asc
    fi

    # Add the repository to Apt sources:
    if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
      info "Adding Docker repository to apt sources"
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
      apt update
    fi

    info "Installing Docker"
    apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi

  if [ "$ENABLE_TAILSCALE" = "true" ]; then
    # Borrowed from https://tailscale.com/download/linux
    info "Installing Tailscale"
    curl -fsSL https://tailscale.com/install.sh | sh
    tailscale up
  fi
}

install_config() {
  info "Installing config files"
  for FILE in ${CONFIG_FILES[@]}; do
    if [ -f ${FILE} ]; then
      info "-> ${FILE} already exists, skipping"
    else
      info "-> installing ${FILE}"
      cp .${FILE} ${FILE}
    fi
  done
}

reload_systemd() {
  info "Reloading systemd"
  systemctl daemon-reload
  for SERVICE in ${SERVICES[@]}; do
    info "-> restarting ${SERVICE}"
    systemctl restart ${SERVICE}
  done
}

remove_root_password() {
  info "Removing root password"
  passwd -d root
}

# pre-checks
if [ -z "$USER" ]; then
  fatal "USER is not set"
fi
if [ $(id -u) -ne 0 ]; then
  fatal "Please run as root"
fi
if [ ! -f /etc/os-release ] || [ "$(cat /etc/os-release | grep -i ubuntu)" == "" ]; then
  fatal "Only Ubuntu is supported"
fi

create_user
add_user_group
install_packages
install_config
reload_systemd
remove_root_password
