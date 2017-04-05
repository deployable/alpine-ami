variable "test_ami" {}

variable "subnet" {
  default = "Var `subnet`"
}

variable "security_group" {
  default = "Var `security_group`"
}

variable "region" {
  default = "ap-southeast-2"
}

provider "aws" {
#  access_key = "ACCESS_KEY_HERE"
#  secret_key = "SECRET_KEY_HERE"
  region     = "${var.region}"
}

resource "aws_instance" "built" {
  ami           = "${var.test_ami}"
  instance_type = "t2.nano"
  subnet_id     = "${var.subnet}"
  vpc_security_group_ids  = [ "${var.security_group}" ]
}


# Debug the dhcp interface
# resource "aws_network_interface" "docker" {
#   subnet_id       = var.subnet_id
# #  private_ips     = [""]
#   security_groups = [var.security_group]
#   attachment {
#     instance     = aws_instance.built.id
#     device_index = 1
#   }
# }

output "address" {
  value = "${aws_instance.built.public_ip}"
}

