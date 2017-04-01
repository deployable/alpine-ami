# Alpine Linux AMI Build

Build an [Alpine Linux](https://www.alpinelinux.org) EC2 AMI with 
 [Packer](https://www.packer.io) and [Ansible](https://www.ansible.com)


## Build AMI

```
brew install packer
brew install ansible
./make.sh
```
The build doesn't pick up the default ssh public key from AWS at the moment so the 
ansible `pubkey` variable is statically configured. It will need to be modified to 
whatever public ssh key you want to use. 


### VirtualBox OVF

The same build can be applied to VirtualBox to produce an OVF appliance

```
./make.sh build_virtualbox
```
_note_ not booting at the moment


## Test

After building you can bring up the AMI on a nano instance via an included
 [Terraform](https://terraform.io) config

```
cd test/
terraform apply -var test_ami=[ami_id]
ssh -i ~/.ssh/id_rsa_alpine admin@[instance_ip]
```

### About

Matt Hoyle - code aatt deployable.co
