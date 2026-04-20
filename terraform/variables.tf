variable "aws_region" {
  description = "AWS region to deploy the SOC lab"
  type        = string
  default     = "eu-west-2"  # London
}

variable "wazuh_ami_id" {
  description = "AMI ID for the Wazuh server EC2 instance"
  type        = string
}
