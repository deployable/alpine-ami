#!/bin/sh

cmd=${1:-}
shift

# Default the command
if [ -z "$cmd" ]; then
  cmd=build
fi

# DEBUG environment var
if [ -n "${DEBUG:-}" ]; then
  PACKER_ARGS="-debug"
fi

# ## Builds
build_virtualbox(){
  pkill -f 'packer build alpine-vagrant.json'
  rm -rf output-virtualbox-iso/
  packer build $PACKER_ARGS alpine-vagrant.json
}

build_ami(){
  packer build $PACKER_ARGS debian-alpine.json
}


# ## Shortcuts

build(){
  build_ami
}

ami(){
  build_ami
}

virtualbox(){
  build_virtualbox
}

$cmd "$@"

