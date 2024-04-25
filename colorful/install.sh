#!/bin/bash

FILES=( \
    /etc/ssh/sshd_config.d/00-colorful.conf \
    /etc/fail2ban/jail.d/00-colorful.conf \
)

if [ $(id -u) -ne 0 ]; then
    echo "colorful: please run as root"
    exit 1
fi

echo "colorful: installing config files"
for FILE in ${FILES[@]}; do
    if [ -f ${FILE} ]; then
        echo " -> colorful: ${FILE} already exists, skipping"
    else
        echo " -> colorful: installing ${FILE}"
        cp .${FILE} ${FILE}
    fi
done

echo "colorful: reloading systemd"
systemctl daemon-reload
systemctl restart ssh

echo "colorful: removing root password"
passwd -d root
