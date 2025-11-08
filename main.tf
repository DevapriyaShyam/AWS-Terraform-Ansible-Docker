provider "aws" {
  region = "eu-west-1"
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the latest Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# ---------------------------------------------------------
# COMMENTED OUT: We’re reusing the existing AWS key pair instead
# ---------------------------------------------------------
# resource "aws_key_pair" "deva_key" {
#   key_name   = "finalkey"
#   public_key = file("C:/Users/DEVAPRIYA/.ssh/finalkey.pub")
# }

# Security Group: allow SSH (22) and HTTP (80)
resource "aws_security_group" "deva_sg" {
  name        = "terraform-sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

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

# Launch EC2 instance
resource "aws_instance" "deva_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "finalkey" # Reuse your existing AWS key pair
  vpc_security_group_ids = [aws_security_group.deva_sg.id]

  tags = {
    Name = "Devapriya-EC2"
  }
}

# Output instance info
output "instance_id" {
  value = aws_instance.deva_instance.id
}

output "instance_public_ip" {
  value = aws_instance.deva_instance.public_ip
}
