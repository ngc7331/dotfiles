#!/bin/bash

__COLORFUL_USAGE='''
USAGE:
$ OPTION=value ./install.sh
or
$ export OPTION=value
$ ./install.sh
or
$ echo "OPTION=value" > .env
$ ./install.sh

OPTIONS:
  NEWUSER: username to create
  ENABLE_SSH: enable SSH server (default: true)
  ENABLE_SSH_KEYGEN: generate SSH key for NEWUSER (default: false), if false, will prompt for public key
  ENABLE_FAIL2BAN: enable fail2ban (default: true)
  ENABLE_UFW: enable UFW (default: true), this is ignored if distro is Ubuntu (which has UFW installed by default)
  ENABLE_DOCKER: enable docker (default: false)
  ENABLE_TAILSCALE: enable tailscale (default: false)
'''

set -e
source utils.sh

ENABLE_SSH=${ENABLE_SSH:-true}
ENABLE_SSH_KEYGEN=${ENABLE_SSH_KEYGEN:-false}
ENABLE_FAIL2BAN=${ENABLE_FAIL2BAN:-true}
ENABLE_UFW=${ENABLE_UFW:-true}
ENABLE_DOCKER=${ENABLE_DOCKER:-false}
ENABLE_TAILSCALE=${ENABLE_TAILSCALE:-false}
NEWUSER=${NEWUSER:-}

dotenv .env

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
if [ "$ENABLE_UFW" = "true" ]; then
  PACKAGES+=(ufw)
fi
if [ "$ENABLE_DOCKER" = "true" ]; then
  # use a standalone
  SERVICES+=(docker)
  CONFIG_FILES+=(/etc/docker/daemon.json)
fi

# stages
create_user() {
  if [ ! -z "$(cat /etc/passwd | grep ${NEWUSER})" ]; then
    info "User ${NEWUSER} already exists, skip creating user"
  else
    info "Creating user: ${NEWUSER}"
    adduser ${NEWUSER}
  fi
}

add_user_group() {
  info "Adding user to sudo group"
  usermod -aG sudo ${NEWUSER}
  if [ "$ENABLE_DOCKER" = "true" ]; then
    info "Adding user to docker group"
    usermod -aG docker ${NEWUSER}
  fi
}

configure_sshkey() {
  info "Configuring SSH key"
  if [ "$ENABLE_SSH_KEYGEN" = "true" ]; then
    if [ -f /home/${NEWUSER}/.ssh/id_ed25519 ]; then
      warn " -> SSH key already exist at /home/${NEWUSER}/.ssh/id_ed25519, skip generating new key"
    else
      info " -> Generating SSH keys to /home/${NEWUSER}/.ssh/id_ed25519"
      sudo -u ${NEWUSER} ssh-keygen -t ed25519 -C "${NEWUSER}@$(hostname)" -f /home/${NEWUSER}/.ssh/id_ed25519 -N ""
    fi
    PUBKEY=$(cat /home/${NEWUSER}/.ssh/id_ed25519.pub)
  else
    read -p "Enter your public key(enter to skip): " PUBKEY
  fi

  if [ -z "$PUBKEY" ]; then
    warn " -> No public key provided, skip adding public key to authorized_keys"
  else
    info " -> Adding public key to authorized_keys"
    mkdir -p /home/${NEWUSER}/.ssh
    chown ${NEWUSER}:${NEWUSER} /home/${NEWUSER}/.ssh
    chmod 700 /home/${NEWUSER}/.ssh
    echo ${PUBKEY} >> /home/${NEWUSER}/.ssh/authorized_keys
    chown ${NEWUSER}:${NEWUSER} /home/${NEWUSER}/.ssh/authorized_keys
    chmod 600 /home/${NEWUSER}/.ssh/authorized_keys
  fi
}

configure_ufw() {
  info "Configuring UFW"
  ufw allow 22/tcp
  ufw default deny incoming
  ufw default allow outgoing
  ufw default allow routed
  ufw enable
  info " -> UFW enabled, only 22/tcp is allowed by default, run 'ufw allow <port>/<proto>' to open more ports"
}

install_packages() {
  info "Installing packages: ${PACKAGES[@]}"
  apt update
  apt install -y ${PACKAGES[@]}

  if [ "$ENABLE_UFW" = "true" ]; then
    configure_ufw
  fi

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
    info "-> installing ${FILE}"
    cp -i .${FILE} ${FILE} || info " -> ${FILE} already exists, skip"
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

reset_root_password() {
  info "Resetting root password"
  local PASSWORD=$(openssl rand -base64 24)
  echo "root:${PASSWORD}" | chpasswd
  info " -> root password reset to ${PASSWORD}"
}

# pre-checks
if [ -z "$NEWUSER" ]; then
  fatal "NEWUSER is not set"
fi
if [ $(id -u) -ne 0 ]; then
  fatal "Please run as root"
fi
if [ -z $(which apt) ]; then
  fatal "Only apt based distros are supported"
fi
if [ ! -z $(which ufw) ]; then
  info "UFW is detected, forcing ENABLE_UFW=true"
  ENABLE_UFW=true
fi

info "Starting installation"
info "NEWUSER=${NEWUSER}"
info "ENABLE_SSH=${ENABLE_SSH}"
info "ENABLE_SSH_KEYGEN=${ENABLE_SSH_KEYGEN}"
info "ENABLE_FAIL2BAN=${ENABLE_FAIL2BAN}"
info "ENABLE_UFW=${ENABLE_UFW}"
info "ENABLE_DOCKER=${ENABLE_DOCKER}"
info "ENABLE_TAILSCALE=${ENABLE_TAILSCALE}"
debug "PACKAGES=${PACKAGES[@]}"
debug "SERVICES=${SERVICES[@]}"
debug "CONFIG_FILES=${CONFIG_FILES[@]}"

create_user
configure_sshkey
install_packages
install_config
add_user_group
reload_systemd
reset_root_password
