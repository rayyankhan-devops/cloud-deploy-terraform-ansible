output "instance-public-ip" {
  value       = aws_instance.my-ec2.public_ip
  description = "Public IP of the EC2 instance"
}
