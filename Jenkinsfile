resource "aws_instance" "backend" {
  ami           = var.ami_id
  instance_type = var.instance_type

  key_name = "jenkins-1"

  tags = {
    Name = "backend-server"
  }
}

output "backend_ip" {
  value = aws_instance.backend.public_ip
}

