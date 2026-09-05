module "ec2" {
  source = "./modules/ec2"
}

resource "local_file" "ansible_inventory" {
  content = <<-EOT
[servers]
node-rayyan ansible_host=${module.ec2.instance-public-ip}

[servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/aws-prac-key.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'
EOT
  filename = "${path.module}/../ansible/inventories/host.ini"
}

resource "terraform_data" "add_to_known_hosts" {
  triggers_replace = [
    module.ec2.instance-public-ip
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for EC2 instance (${module.ec2.instance-public-ip}) SSH port 22..."
      for i in {1..30}; do
        if nc -z -w 3 ${module.ec2.instance-public-ip} 22 2>/dev/null; then
          ssh-keygen -R "${module.ec2.instance-public-ip}" 2>/dev/null || true
          ssh-keyscan -H "${module.ec2.instance-public-ip}" >> ~/.ssh/known_hosts 2>/dev/null
          echo "Successfully added ${module.ec2.instance-public-ip} to ~/.ssh/known_hosts"
          exit 0
        fi
        sleep 3
      done
      echo "Warning: Timed out waiting for port 22 on ${module.ec2.instance-public-ip}"
    EOT
  }

  depends_on = [module.ec2]
}

