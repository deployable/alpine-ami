# Alpine Linux AMI Build

Build an [Alpine Linux](https://www.alpinelinux.org) EC2 AMI with or OVA
with [Packer](https://www.packer.io) and [Ansible](https://www.ansible.com).


## Setup

The build requires `packer` and `ansible-playbook` to be installed.

On a mac, use [brew](https://brew.sh).
```shell
brew install packer
brew install ansible
```

On Linux, [download](https://www.packer.io/downloads.html) or check your package manager.
Ansible is available via `pip install ansible`, on epel in RHEL and on `ppa:ansible/ansible` in Ubuntu.


## Build AMI

```shell
git clone https://github.com/deployable/alpine-ami && cd alpine-ami
vi debian-alpine.json # set or delete `subnet_id` and `security_group_id`
./make.sh ami
```

_Note:_ The build doesn't pick up the default ssh public key from AWS at the moment so the 
ansible `pubkey` variable is locally configured. If you want to regenerate the keys just
delete them from `./playbook` and the next make will create new ones.


### VirtualBox OVF

The same build can be applied to VirtualBox to produce an OVF appliance.

```
./make.sh virtualbox
```
_Note:_ no guest additions installed


## Test

After building you can bring up the AMI on a nano instance via an included
 [Terraform](https://terraform.io) config.

```
./make.sh terraform ami-[id]
./make.sh ssh [instance_ip]
```

For Virtualbox you need to import the OVF and add a host only adapter, a 
bridge adapter, or on NAT map a port to 22. Then you can ssh to it

```
./make.sh ssh [vbox_ip]
```

### About

Matt Hoyle - code aatt deployable.co
