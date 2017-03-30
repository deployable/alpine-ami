#!/bin/sh
set -uex

echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main
http://dl-cdn.alpinelinux.org/alpine/v3.5/community' > /etc/apk/repositories

# Setup
apk update
apk add --no-cache iproute2 iptables ip6tables iputils coreutils util-linux grep gzip jq curl  tar bash e2fsprogs openssh procps pstree gawk sed vim less python2 py2-pip sudo

# Boot
rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add mdev sysinit
rc-update add hwclock boot
rc-update add modules boot
rc-update add sysctl boot
rc-update add hostname boot
rc-update add bootmisc boot
rc-update add syslog boot
rc-update add sshd boot
rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown

# AWS
pip install --upgrade pip
pip install awscli


adduser -D -h /home/admin admin
passwd -d $(uuid) admin
passwd -d $(uuid) root

df -h

setup-disk -v -m sys -s 512 /dev/xvdf

fdisk -l /dev/xvdf