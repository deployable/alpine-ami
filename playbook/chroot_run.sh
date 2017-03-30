#!/bin/sh
set -uex

rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add mdev sysinit
rc-update add hwclock boot
rc-update add modules boot
rc-update add sysctl boot
rc-update add hostname boot
rc-update add bootmisc boot
rc-update add syslog boot
rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown

apk update
apk add --no-cache iproute2 grep gzip jq wget curl coreutils tar bash e2fsprogs procps pstree gawk sed vim less python2 py2-pip
pip install --upgrade pip
pip install awscli
