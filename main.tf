provider "aws" {
  region = "us-east-1"
}
#SG
resource "aws_instance" "TV" {
  ami           = "ami-0ca4d5db4872d0c28"
  instance_type = "t3.micro"

  tags = {
    Name = "Channel123"
  }
}
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

