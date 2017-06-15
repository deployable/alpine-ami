# Alpine Linux AMI Build

Build an [Alpine Linux](https://www.alpinelinux.org) EC2 AMI, Virtualbox OVF or PXE initrd
with [Packer](https://www.packer.io) and [Ansible](https://www.ansible.com).


- [Install](#install)
- [EC2 AMI](#build-ami)
- [Vagrant box](#build-vagrant-box)
- [VirtualBox OVF](#build-virtualbox-ovf)
- [PXE initrd](#build-pxe-initrd)


## Install

Clone the repo

```shell
git clone https://github.com/deployable/alpine-ami && cd alpine-ami
```

The build requires `packer` and `ansible-playbook` to run.

On a mac, use [brew](https://brew.sh).
```shell
brew install packer
brew install ansible
```

On Linux, [download](https://www.packer.io/downloads.html) or check your package 
manager. Ansible is available via `pip install ansible`, on epel in RHEL and on 
`ppa:ansible/ansible` in Ubuntu.


### Testing

Included is a [Terraform](https://terraform.io) config to launch the instance. 


## Build AMI

Building requires a VPC subnet and security group that allows SSH access.
You can specify a region as well. 

```shell
./make.sh aws subnet-XXXXXXXX sg-XXXXXXXX eu-central-1
```

_Note:_ The build doesn't pick up the default ssh public key from AWS at the moment so the 
ansible `pubkey` variable is locally configured. If you want to regenerate the key just
delete them from `./playbook` and the next `make` will create a new one.


### Test

After building you can bring up the AMI (output at the end of the build step) on a nano 
instance via an included [Terraform](https://terraform.io) config.

```shell
./make.sh test ami-[id] subnet-XXXXXXXX sg-XXXXXXXX eu-central-1
./make.sh ssh [instance_ip]
./make.sh test_destroy ami-[id] subnet-XXXXXXXX sg-XXXXXXXX eu-central-1
```


### Environment

The subnet, security group and region can be set in your shells environment for the build 
and test commands to use.

```
export AWS_SUBNET=X
export AWS_SECURITY_GROUP=X
export AWS_REGION=X
```



## Build Vagrant Box

The same build can be applied to produce a Vagrant box 

```shell
./make.sh vagrant
```
_Note:_ The guest additions are not installed


### Test

Requries [Vagrant](https://vagrantup.com).

```shell
./make.sh add_vagrant
vagrant ssh
```



## Build VirtualBox OVF

The same build can be applied to VirtualBox to produce an OVF appliance.

```shell
./make.sh virtualbox
```
_Note:_ The guest additions are not installed


### Test

For Virtualbox you need to import the OVF and add a host only adapter, a 
bridge adapter, or NAT mapping to port to 22. Then you can ssh to it

```shell
VBoxManage import ./output-vbox/alpine-vbox.ovf 
VBoxManage modifyvm alpine-vbox --natpf1 "tcp-port,tcp,,2202,,22"
VBoxManage startvm alpine-vbox --type separate
SSH_ARGS="-p 2202" ./make.sh ssh localhost
```


## Build PXE initrd

```shell
./make.sh pxe
```
The initrd is exported to `output-pxe-3.5.2/pxerd`

## Issues

### Slow VM startup

Alpine 3.5 can run out of entropy making sshd startup slow: https://bugs.alpinelinux.org/issues/6635


## About

Matt Hoyle - code aatt deployable.co
