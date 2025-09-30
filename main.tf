provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "TV" {
  ami           = "ami-08982f1c5bf93d976"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.Kushi.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.security.id]
  key_name = aws_key_pair.my_key.key_name


  tags = {
    Name = "Channel"
  }
}

resource "aws_eip" "static_ip" {
  instance = aws_instance.TV.id
}
#SG
resource "aws_security_group" "security" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

resource "tls_private_key" "KeyPair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_key" {
  key_name   = "terraform-key"
  public_key = tls_private_key.KeyPair.public_key_openssh
}

resource "local_file" "private_key_file" {
  content          = tls_private_key.KeyPair.private_key_pem
  filename = pathexpand("~/.ssh/P1.pem")
  file_permission  = "0600"
}




resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Kushi.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "Kushi" {
  cidr_block = "10.0.3.0/24"
  vpc_id = aws_vpc.main.id
  availability_zone = "us-east-1a"
}

resource "aws_network_interface" "test" {
  subnet_id = aws_subnet.Kushi.id
}

