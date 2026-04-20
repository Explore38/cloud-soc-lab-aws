# Security Group
resource "aws_security_group" "soc_sg" {
  name        = "soc-lab-sg"
  description = "Security group for SOC lab instances"
  vpc_id      = aws_vpc.soc_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
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

# Wazuh EC2 Instance
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
