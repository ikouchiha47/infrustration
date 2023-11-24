provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "talon_api_sg" {
  name = "TaolnAPISg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "tf-key-pair" {
  key_name = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair.pem"
  file_permission = "400"
}



resource "aws_instance" "talon_server" {
  ami = "ami-027a0367928d05f3e"
  instance_type = "t2.micro"
  key_name = "tf-key-pair"
  associate_public_ip_address = true

  iam_instance_profile = "ecsInstanceRole"
  vpc_security_group_ids = [aws_security_group.talon_api_sg.id]

  user_data = base64encode(templatefile("${path.module}/templates/ecs/setup.sh", { IMAGE = var.DOCKER_IMAGE, AWS_ACCOUNT = var.AWS_ACCOUNT }))

  tags = {
      Name = "talon-api-instance"
  }
}
