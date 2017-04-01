#!/bin/sh

cmd=${1:-}
if [ -z "$cmd" ]; then
  cmd=build
fi

build_virtualbox(){
  pkill -f 'packer build alpine-vagrant.json'
  rm -rf output-virtualbox-iso/
  packer build alpine-vagrant.json
}

build_ami(){
  packer build debian-alpine.json
}

build(){
  build_ami
}

$cmd "$@"

