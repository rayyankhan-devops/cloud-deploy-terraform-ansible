output "ec2_public_ip" {
  description = "Public IP of the EC2 instance for Ansible"
  value       = module.ec2.instance-public-ip
}
