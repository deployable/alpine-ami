#!/bin/sh

# Run the various things

# Setting `DEBUG` will turn debug on around the place.

#    DEBUG=1 ./make.sh ami

# Setting `PACKER_ARGS` will pass them directly to `packer`.

#    PACKER_ARGS="-debug" ./make.sh ami

# Same for `SSH_ARGS`, `VAGRANT_ARGS`, `TERRAFORM_ARGS`


# ## Setup
set -ue

rundir=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)")
canonical="$rundir/$(basename -- "$0")"
cd "$rundir"


# Get the command, or default it
cmd=${1:-}
if [ -n "$cmd" ]; then
  shift
else 
  cmd=build
fi


# AWS Environment vars
AWS_SUBNET="${AWS_SUBNET:-}"
AWS_SECURITY_GROUP="${AWS_SECURITY_GROUP:-}"
AWS_REGION=${AWS_REGION:-ap-southeast-2}
AWS_AMI=${AWS_AMI:-ami-881317eb}

# Push args to underlying utilities
PACKER_ARGS="${PACKER_ARGS:-}"
TERRAFORM_ARGS="${TERRAFORM_ARGS:-}"
VAGRANT_ARGS="${VAGRANT_ARGS:-}"
SSH_ARGS="${SSH_ARGS:-}"

# DEBUG environment var
if [ -n "${DEBUG:-}" ]; then
  set -x
  PACKER_ARGS="$PACKER_ARGS -debug"
  TF_LOG=debug
  VAGRANT_ARGS="$VAGRANT_ARGS --debug"
  SSH_ARGS="$SSH_ARGS -v"
fi


# Debian AMI lookup from region

get_ami_from_region(){
  local_region=$1
  awk '
    BEGIN { f=1; }
    { 
      if ($1 == "'$local_region'" ){ 
        print $2;
        f=0;
        exit f; 
      }
    }
    END{ exit f; }
  ' .ami-env
}


# ## Builds

# Build a base ovf to build virtualbox/vagrant boxes with via the
# [`virtualbox-ovf`](https://www.packer.io/docs/builders/virtualbox-ovf.html) builder.
build_virtualbox_builder(){
  build_sshkeys_conditional
  set +e
  pkill -f 'packer build alpine-virtualbox-builder-3.6.json'
  rm -rf output-builder/
  set -e
  packer build -force $PACKER_ARGS alpine-virtualbox-builder-3.6.json
}

build_virtualbox_builder_pxe(){
  build_sshkeys_conditional
  set +e
  pkill -f 'packer build alpine-virtualbox-builder-3.6.json'
  rm -rf output-builder/
  set -e
  packer build -force $PACKER_ARGS alpine-virtualbox-builder-3.6.json
}

# Build a virtualbox .ovf from iso
build_virtualbox(){
  build_sshkeys_conditional
  set +e
  pkill -f 'packer build alpine-vagrant.json'
  pkill -f 'packer build alpine-virtualbox.json'
  rm -rf output-vbox/
  set -e
  packer build $PACKER_ARGS alpine-virtualbox.json
}

# Build a vagrant .box from iso
build_vagrant(){
  build_sshkeys_conditional
  set +e
  pkill -f 'packer build alpine-vagrant.json'
  pkill -f 'packer build alpine-virtualbox.json'
  rm -rf output-vagrant/
  set -e
  packer build $PACKER_ARGS alpine-vagrant.json
}

# Build a pxe initrd frome the virtualbox builder ovf.
build_pxe(){
  if [ ! -f ./output-builder-3.6.1/alpine-vbox-builder-3.6.1.ovf ]; then
    echo "need to run 'build_virtualbox_builder'"
    return 1
  fi
  build_sshkeys_conditional
  set +e
  pkill -f 'packer build alpine-pxe-3.6.json'
  set -e
  packer build -force $PACKER_ARGS alpine-pxe-3.6.json
}


# Build an AWS ami in a region
# requires a subnet and sec group to build in.
build_ami(){
  local_subnet=${1:-$AWS_SUBNET}
  local_group=${2:-$AWS_SECURITY_GROUP}
  local_region=${3:-${AWS_REGION:-ap-southeast-2}}
  local_ami=$(get_ami_from_region "$local_region")

  build_sshkeys_conditional
  
  packer build $PACKER_ARGS \
    -var subnet=$local_subnet \
    -var security_group=$local_group \
    -var regions=$local_region \
    -var ami=$local_ami \
    debian-alpine.json
}

# Create an ssh key if it doesn't exist
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

build_clean(){
  cd "$rundir"/
  rm -rf output-*
}

# ## Run

run_vm_destroy(){
  local_vm=$1
  VBoxManage controlvm $local_vm poweroff
  VBoxManage unregistervm $local_vm --delete
}

run_vagrant_add(){
  vagrant box add output-vagrant-alpine-3.5.2.box --force --name dply/alpine_ami
}

run_vagrant(){
  run_vagrant_add
  vagrant destroy --force
  vagrant up
}

# Connect to an ec2 build box
run_ami_ssh(){
  local_ip=$1
  ssh $SSH_ARGS -i ec2_amazon-ebssurrogate.pem admin@$local_ip
}

# Connect to a build box
run_ssh(){
  local_ip=$1
  set +e
  while true; do
    ssh $SSH_ARGS -o ConnectTimeout=10 -i "$rundir"/playbook/id_rsa_alpine admin@$local_ip
    if [ "$?" == "0" ]; then 
      break
    fi
    echo retrying
    sleep 10
  done
  set -e
}

run_terraform(){
  local_ami=$1
  local_subnet=${2:-$AWS_SUBNET}
  local_group=${3:-$AWS_SECURITY_GROUP}
  local_region=${4:-${AWS_REGION:-ap-southeast-2}}

  cd "$rundir"/test
  terraform apply $TERRAFORM_ARGS \
    -var test_ami=$local_ami \
    -var subnet="$local_subnet" \
    -var security_group="$local_group" \
    -var region="$local_region"
}

run_terraform_destroy(){
  local_ami=$1
  local_subnet=${2:-$AWS_SUBNET}
  local_group=${3:-$AWS_SECURITY_GROUP}
  local_region=${4:-${AWS_REGION:-ap-southeast-2}}

  cd "$rundir"/test
  terraform apply $TERRAFORM_ARGS \
    -var test_ami=$local_ami \
    -var subnet="$local_subnet" \
    -var security_group="$local_group" \
    -var region="$local_region"
}

run_help(){
  echo 'Help:'
  echo ' aws [subnet] [sg] [region]     Build the aws ami'
  echo ' vagrant                        Build the .box'
  echo ' virtualbox                     Build the .ovf'
  echo ' keys                           Generate ssh keys'
  echo
  echo ' ssh [ip]                       SSH with keys to ip'
  echo ' test [ami] [subnet] [sg] [region]'
  echo '                                Bring up new ami with terraform'
  echo ' test_destroy [ami] [subnet] [sg] [region]'
  echo '                                Destroy the terraform resource'
}


# ## Shortcuts

case $cmd in
  'build'|'aws')  build_ami "$@";;
  'builder')      build_virtualbox_builder "$@";;
  'clean')        build_clean "$@";;
  'vbox')         build_virtualbox "$@";;
  'virtualbox')   build_virtualbox "$@";;
  'vagrant')      build_vagrant "$@";;
  'pxe')          build_pxe "$@";;
  'keys')         build_sshkeys "$@";;
  'ssh')          run_ssh "$@";;
  'test')         run_terraform "$@";;
  'test_destroy') run_terraform_destroy "$@";;
  '-h'|'--help')  run_help;;
  *)              $cmd "$@";;
esac

