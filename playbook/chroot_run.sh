#!/bin/sh
set -uex

# Boot
rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add mdev sysinit
#rc-update add swap boot
rc-update add hwclock boot
rc-update add modules boot
rc-update add sysctl boot
rc-update add urandom boot
rc-update add acpid boot
rc-update add hostname boot
rc-update add dhcpcd boot
rc-update add networking boot
rc-update add bootmisc boot
rc-update add syslog boot
rc-update add sshd boot
rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add urandom shutdown
rc-update add savecache shutdown

# AWS
#apk add python py2-pip
#pip install --upgrade pip
#pip install awscli

adduser -D -h /home/admin admin
pwd="$(uuidgen)"
echo "$pwd
$pwd" | passwd admin
pwd="$(uuidgen)"
echo -e "$pwd
$pwd" | passwd root

df -h
