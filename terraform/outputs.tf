output "vpc_id" {
  value = aws_vpc.soc_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "wazuh_server_public_ip" {
  value = aws_instance.wazuh_server.public_ip
}
