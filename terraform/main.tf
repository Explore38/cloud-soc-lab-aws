terraform {
  required_version = ">= 1.5.0"

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

# VPC
resource "aws_vpc" "soc_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "soc-lab-vpc"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.soc_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "soc-lab-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.soc_vpc.id

  tags = {
    Name = "soc-lab-igw"
  }
}

# Route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.soc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "soc-lab-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security group for SOC instances
resource "aws_security_group" "soc_sg" {
  name        = "soc-lab-sg"
  description = "Security group for SOC lab instances"
  vpc_id      = aws_vpc.soc_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # later we’ll lock this down
  }

  # HTTP/HTTPS (for dashboards / web UIs)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "soc-lab-sg"
  }
}

# Example EC2 instance for Wazuh (we’ll refine later)
resource "aws_instance" "wazuh_server" {
  ami                    = var.wazuh_ami_id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.soc_sg.id]

  tags = {
    Name = "wazuh-server"
    Role = "siem"
  }
}
