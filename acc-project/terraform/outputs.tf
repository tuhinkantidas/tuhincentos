output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.demo.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.demo.public_ip
}

output "application_url" {
  description = "Application endpoint"
  value       = "http://${aws_instance.demo.public_ip}"
}
