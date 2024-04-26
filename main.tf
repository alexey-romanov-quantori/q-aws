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

variable "vpc_id" {
  type    = string
  default = "vpc-024cf058980b63412"
}

variable "subnet_id" {
  type    = string
  default = "subnet-07549c87757e073ea"
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
  subnet_id = var.subnet_id
  security_groups = [aws_security_group.allow_ssh_http.id]
}

# - Create a security group to allow traffic from your IP address to port 22 and allow traffic from the internet
# to the port that your application requires. Attach this group to the EC2
resource "aws_security_group" "allow_ssh_http" {
  name        = "SG_alexey_romanov_tf_allow_ssh_http"
  description = "Allow inbound ssh traffic on port 22 and http traffic on port 80; allows all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_ssh_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# - Create a s3 bucket "qnt-bucket-tf-*your_name*"
resource "aws_s3_bucket" "bucket" {
  bucket = "qnt-bucket-tf-alexey-romanov"

  tags = {
    Name        = "Bucket created by terraform script"
    Environment = "Dev"
  }
}

# - Create a role that must follow this constraint: Permission to perform all operations on the s3 bucket you created before. Attach this role to the EC2
