variable "test_ami" {}

provider "aws" {
#  access_key = "ACCESS_KEY_HERE"
#  secret_key = "SECRET_KEY_HERE"
  region     = "ap-southeast-2"
}

resource "aws_instance" "example" {
  ami           = "${var.test_ami}"
  instance_type = "t2.nano"
  subnet_id     = "subnet-85f0fcc3"
  key_name      = "mattapsydney"
  vpc_security_group_ids  = ["sg-2b52e14f"]
}