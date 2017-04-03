#!/bin/sh

# Run the various things

# Setting DEBUG will turn debug on around the place.

#    DEBUG=1 ./make.sh ami

# Setting PACKER_ARGS will pass them directly to `packer`.

#    DEBUG=1 ./make.sh ami


# ## Setup
set -uex

rundir=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)")
canonical="$rundir/$(basename -- "$0")"
cd "$rundir"

cmd=${1:-}
if [ -n "$cmd" ]; then
  shift
fi

# Default the command
if [ -z "$cmd" ]; then
  cmd=build
fi

if [ -z "${PACKER_ARGS:-}" ]; then
  PACKER_ARGS=''
fi

# DEBUG environment var
if [ -n "${DEBUG:-}" ]; then
  PACKER_ARGS="$PACKER_ARGS -debug"
fi

# ## Builds

build_virtualbox(){
  build_sshkeys_conditional
  set +e
  pkill -f 'packer build alpine-vagrant.json'
  rm -rf output-virtualbox-iso/
  set -e
  packer build $PACKER_ARGS alpine-vagrant.json
}

build_ami(){
  build_sshkeys_conditional
  packer build $PACKER_ARGS debian-alpine.json
}

build_sshkeys_conditional(){
  if [ ! -f "$rundir"/playbook/id_rsa_alpine ]; then
    build_sshkeys
  else
    echo "'playbook/id_rsa_alpine' already generated"
  fi
}

build_sshkeys(){
  ssh-keygen -f "$rundir"/playbook/id_rsa_alpine -t rsa -b 3072 -N ''
}


# ## Run

run_ssh(){
  local_ip=$1
  set +e
  while true; do
    ssh -o ConnectTimeout=10 -i "$rundir"/playbook/id_rsa_alpine admin@$local_ip
    if [ "$?" == "0" ]; then 
      break
    fi
    echo retrying
    sleep 5
  done
  set -e
}

run_terraform(){
  local_ami=$1
  cd "$rundir"/test
  terraform apply -var test_ami=$local_ami
}


# ## Shortcuts

case $cmd in
  'build')      build_ami "$@";;
  'ami')        build_ami "$@";;
  'virtualbox') build_virtualbox "$@";;
  'keys')       build_sshkeys "$@";;
  'ssh')        run_ssh "$@";;
  'terraform')  run_terraform "$@";;
  *)            $cmd "$@";;
esac

