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

if [ -z "${SSH_ARGS:-}" ]; then
  SSH_ARGS=''
fi

# DEBUG environment var
if [ -n "${DEBUG:-}" ]; then
  PACKER_ARGS="$PACKER_ARGS -debug"
  SSH_ARGS="$SSH_ARGS -v"
fi

# ## Builds

build_virtualbox_builder(){
  build_sshkeys_conditional
  set +e
  pkill -f 'packer build alpine-virtualbox-builder.json'
  rm -rf output-builder/
  set -e
  packer build $PACKER_ARGS alpine-virtualbox-builder.json
}

build_virtualbox(){
  if [ ! -f ./output-builder//alpine-vbox-builder.ovf ]; then
    echo "need to run 'build_virtualbox_builder'"
    return 1
  fi
  build_sshkeys_conditional
  set +e
  pkill -f 'packer build alpine-vagrant.json'
  pkill -f 'packer build alpine-virtualbox.json'
  rm -rf output-vbox/
  set -e
  packer build $PACKER_ARGS alpine-virtualbox.json
}

build_vagrant(){
  if [ ! -f ./output-builder//alpine-vbox-builder.ovf ]; then
    echo "need to run 'build_virtualbox_builder'"
    return 1
  fi
  build_sshkeys_conditional
  set +e
  pkill -f 'packer build alpine-vagrant.json'
  pkill -f 'packer build alpine-virtualbox.json'
  rm -rf output-vagrant/
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

run_vm_destroy(){
  local_vm=$1
  VBoxManage controlvm $local_vm poweroff
  VBoxManage unregistervm $local_vm --delete
}

run_vagrant_add(){
  vagrant box add ./packer_virtualbox-iso_virtualbox.box --force --name dply/alpine_ami
}

run_ami_ssh(){
  local_ip=$1
  ssh $SSH_ARGS -i ec2_amazon-ebssurrogate.pem admin@$local_ip
}

run_ssh(){
  local_ip=$1
  set +e
  while true; do
    ssh $SSH_ARGS -o ConnectTimeout=10 -i "$rundir"/playbook/id_rsa_alpine admin@$local_ip
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

run_help(){
  echo 'Help:'
  echo ' build | aws      Build the aws ami'
  echo ' virtualbox       Build the ova'
  echo ' keys             Generate ssh keys'
  echo ' ssh [ip]         SSH with keys to ip'
  echo ' terraform [ami]  Bring up new ami with terraform'
}

# ## Shortcuts

case $cmd in
  'build'|'aws')  build_ami "$@";;
  'builder')      build_virtualbox_builder "$@";;
  'vbox')         build_virtualbox "$@";;
  'virtualbox')   build_virtualbox "$@";;
  'vagrant')      build_vagrant "$@";;
  'keys')         build_sshkeys "$@";;
  'ssh')          run_ssh "$@";;
  'terraform')    run_terraform "$@";;
  '-h'|'--help')  run_help;;
  *)              $cmd "$@";;
esac

