variable "test_ami" {}

provider "aws" {
#  access_key = "ACCESS_KEY_HERE"
#  secret_key = "SECRET_KEY_HERE"
  region     = "ap-southeast-2"
}

resource "aws_instance" "built" {
  ami           = "${var.test_ami}"
  instance_type = "t2.nano"
  subnet_id     = "subnet-85f0fcc3"
  key_name      = "mattapsydney"
  vpc_security_group_ids  = ["sg-2b52e14f"]
  private_ip = "172.30.1.201"
}

# Debug dhcp interface
resource "aws_network_interface" "docker" {
  subnet_id       = "subnet-85f0fcc3"
#  private_ips     = [""]
  security_groups = ["sg-2b52e14f"]
  attachment {
    instance     = "${aws_instance.built.id}"
    device_index = 1
  }
}

output "address" {
  value = "${aws_instance.built.public_ip}"
}
