provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "TV" {
  ami           = "ami-08982f1c5bf93d976"
  instance_type = "t3.micro"

  tags = {
    Name = "Channel123"
  }
}
