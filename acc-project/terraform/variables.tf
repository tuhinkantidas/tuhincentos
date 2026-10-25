variable "aws_region" {
  description = "AWS region for the demo resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short prefix for demo resources"
  type        = string
  default     = "acc-reliability-demo"
}

variable "my_ip_cidr" {
  description = "Your public IPv4 address in CIDR notation, e.g. 203.0.113.10/32. Restricts HTTP access."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type; check current pricing and account quota before applying."
  type        = string
  default     = "t3.micro"
}
