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
./make.sh
```

_Note:_ The build doesn't pick up the default ssh public key from AWS at the moment so the 
ansible `pubkey` variable is statically configured. It will need to be modified to 
whatever public ssh key you want to use. 


### VirtualBox OVF

The same build can be applied to VirtualBox to produce an OVF appliance.

```
./make.sh build_virtualbox
```
_Note:_ no guest additions installed


## Test

After building you can bring up the AMI on a nano instance via an included
 [Terraform](https://terraform.io) config.

```
cd test/
terraform apply -var test_ami=ami-[id]
ssh -i ~/.ssh/id_rsa_alpine admin@[instance_ip]
```

### About

Matt Hoyle - code aatt deployable.co
