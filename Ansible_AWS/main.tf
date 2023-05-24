# --- root/main.tf ---

locals{
    vpc_id = "vpc-057914d1ee3206f9d"
    subnet_id = "subnet-051583a7ec259140d"
    ssh_user = "ubuntu"
    key_name = "devops_user"
    private_key_path = "/Users/chris.mcklveen/Projects/Ansible/Ansible_AWS/keys"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "nginx" {
  name = "nginx_access"
  vpc_id = "local.vpc_id"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami = "ami-0db245b76e5c21ca1"
  subnet_id = "subnet-051583a7ec259140d"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  security_groups = [aws_security_group.nginx.id]
  key_name = local.key_name

  provisioner "remote-exec" {
    inline = [ "echo 'Wait until SSH is ready'" ]

    connection {
      type = "ssh"
      user = local.ssh_user
      private_key = file(local.private_key_path)
      host = aws_instance.nginx.public_ip
  }
  }

  provisioner "local-exec" {
    command = "anisible-playbook -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yml"
  
  }

output "nginx_ip" {
  value = "aws_instance.nginx.public_ip"
}
}