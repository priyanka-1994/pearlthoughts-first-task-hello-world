provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "allow_ssh_http" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                         = "ami-09040d770ffe2224f"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  security_groups             = [aws_security_group.allow_ssh_http.name]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nodejs npm
              curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
              sudo apt install -y nodejs
              git clone https://github.com/priyanka-1994/pearlthoughts-first-task-hello-world.git
              cd pearlthoughts-first-task-hello-world
              npm install
              npm run build
              npm run start
              EOF

  tags = {
    Name = "pearlthoughts-first-task-hello-world"
  }
}

output "instance_ip" {
  description = "The public IP of the instance"
  value       = aws_instance.app.public_ip
}

