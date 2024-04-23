terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.46.0"
    }
  }
  backend "s3" {
    bucket = "qnt-clouds-for-pe-tfstate"
    key    = "alexey-romanov/terraform-homework"
    region = "us-east-2"
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

provider "aws" {
  region = var.aws_region
}

# Create an EC2 instance (instance type = t3a.small) in the public subnet and enable getting public IP.
# Use the VPC vpc-024cf058980b63412 and one of the subnets (subnet-07549c87757e073ea, subnet-058c0197a05db2379).
# Use user data script to install required packages to run your project code.

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "alexey_romanov_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.small"

  tags = {
    Name    = "alexey-romanov-tf"
    env     = "dev"
    owner   = "alexey.romanov@quantori.com"
    project = "INFRA"
  }

  associate_public_ip_address = true
  subnet_id = "subnet-07549c87757e073ea"
}
