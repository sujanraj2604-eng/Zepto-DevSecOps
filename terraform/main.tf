terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create VPC
resource "aws_vpc" "zepto_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Zepto-VPC"
  }
}

# Create public subnet
resource "aws_subnet" "zepto_public" {
  vpc_id                  = aws_vpc.zepto_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Zepto-Public-Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "zepto_igw" {
  vpc_id = aws_vpc.zepto_vpc.id

  tags = {
    Name = "Zepto-IGW"
  }
}

# Route table
resource "aws_route_table" "zepto_rt" {
  vpc_id = aws_vpc.zepto_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.zepto_igw.id
  }

  tags = {
    Name = "Zepto-Public-RT"
  }
}

# Route table association
resource "aws_route_table_association" "zepto_rta" {
  subnet_id      = aws_subnet.zepto_public.id
  route_table_id = aws_route_table.zepto_rt.id
}

# Security group
resource "aws_security_group" "zepto_sg" {
  name        = "Zepto-SG"
  description = "Zepto web server security group"
  vpc_id      = aws_vpc.zepto_vpc.id

  ingress {
    description = "Web application"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access restricted to administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Zepto-SG"
  }
}

# Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# EC2 instance
resource "aws_instance" "zepto_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.zepto_public.id
  vpc_security_group_ids      = [aws_security_group.zepto_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "Zepto-Application-Server"
  }
}
