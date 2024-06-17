provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami                    = "ami-09040d770ffe2224f"
  instance_type          = "t2.micro"      // Instance type
  key_name               = "ansible-ohio" // SSH key pair for access
  subnet_id              = "subnet-05a4e0d31adced8af"   // Subnet ID where the instance will be launched
  associate_public_ip_address = true    // Assign a public IP

  tags = {
    Name = "NestJS-EC2-Instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nodejs npm"
      
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/path/to/your/private_key.pem")
      host        = self.public_ip
    }
  }
}
