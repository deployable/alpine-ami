#!/bin/sh
set -uex

#setup-disk -v -m sys -s 512 /dev/xvdf
#echo "setup [$?]"
fdisk -l /dev/xvdf
echo "fdisk [$?]"


echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main
http://dl-cdn.alpinelinux.org/alpine/v3.5/community' > /etc/apk/repositories

# Setup
apk update
apk add --no-cache \
  iproute2 iptables ip6tables iputils \
  e2fsprogs coreutils util-linux syslinux \
  sudo bash \
  openssh dhcpcd
#  procps pstree \
# grep gzip tar bash gawk sed less vim jq curl \
#  python2 py2-pip 


extlinux --install /boot
echo "extlinux [$?]"

#cp /etc/apk/repositories /etc/apk/repositories.normal
#echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
#apk update 
#apk add grub@testing

#grub-install /dev/xvdf

#cp /etc/apk/repositories /etc/apk/repositories.testing
#cp /etc/apk/repositories.normal /etc/apk/repositories
#apk update


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
rc-update add netdebug boot
rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown

# AWS
#pip install --upgrade pip
#pip install awscli



adduser -D -h /home/admin admin
pwd="$(uuidgen)"
echo -e "admin\nadmin\n" | passwd admin
pwd="$(uuidgen)"
echo -e "$pwd\n$pwd\n" | passwd root

df -h