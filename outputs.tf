output "instance_ip" {
  description = "The public IP of the instance"
  value       = aws_instance.app.public_ip
}

