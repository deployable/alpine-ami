#!/bin/sh

cmd=${1:-}
if [ -z "$cmd" ]; then
  cmd=build
fi

if [ -n "${DEBUG:-}" ]; then
  PACKER_ARGS="-debug"
fi

build_virtualbox(){
  pkill -f 'packer build alpine-vagrant.json'
  rm -rf output-virtualbox-iso/
  packer build $PACKER_ARGS alpine-vagrant.json
}

build_ami(){
  packer build $PACKER_ARGS debian-alpine.json
}

build(){
  build_ami
}

$cmd "$@"

