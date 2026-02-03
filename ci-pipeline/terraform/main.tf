provider "aws" {
  region = var.region
}

resource "aws_instance" "frontend" {
  ami           = "ami-0532be01f26a3de55" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = "c8.local"
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-0b6c6ebed2801a5cb" # Ubuntu 21.04
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = "u21.local"
  }
}
