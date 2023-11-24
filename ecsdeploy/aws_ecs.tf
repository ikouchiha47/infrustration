provider "aws" {
  region = "ap-south-1"
}

// Create vpc and add a subnet
// Add a routing table and direct all traffic from internet
// to the subnet
resource "aws_vpc" "mitil_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags       = {
      Name = "Talon VPC"
  }
}

resource "aws_internet_gateway" "mitil_server_ig" {
  vpc_id = aws_vpc.mitil_vpc.id
}

resource "aws_route_table" "mitil_sever_rt" {
  vpc_id =  aws_vpc.mitil_vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.mitil_server_ig.id
    }
}

resource "aws_subnet" "mitil_server_subnet" {
    vpc_id = aws_vpc.mitil_vpc.id
    cidr_block              = cidrsubnet(aws_vpc.mitil_vpc.cidr_block, 8, 1)
    map_public_ip_on_launch = true
    availability_zone = "ap-south-1b"
}


resource "aws_route_table_association" "mitil_server_route" {
  route_table_id = aws_route_table.mitil_sever_rt.id
  subnet_id = aws_subnet.mitil_server_subnet.id
}

resource "aws_security_group" "talon_api_sg" {
  name = "MitilAPISg"
  vpc_id = aws_vpc.mitil_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9090
    to_port     = 9090
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
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
}


// Create a auto scaling group which with a variable
// ECS_CLUSTER set to server Cluster

resource "aws_ecs_cluster" "mitil_server_cluster" {
  name = "mitil-server-cluster"
}

resource "aws_launch_template" "mitil_server_launch_configuration" {
  name_prefix = "talon-server"
  image_id      = "ami-027a0367928d05f3e"
  instance_type = "t2.micro"
  key_name      = "tf-key-pair"
  vpc_security_group_ids = [aws_security_group.talon_api_sg.id]

  /*
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.talon_api_sg.id] 
  }
  */

  iam_instance_profile {
    name = "ecsInstanceRole"
  }

  user_data = filebase64("${path.module}/templates/ecs/ecs.sh")
}

resource "aws_autoscaling_group" "mitil_server_ecs_asg" {
  name                = "MitilServerAsg"
  vpc_zone_identifier = [aws_subnet.mitil_server_subnet.id]

  launch_template {
    id = aws_launch_template.mitil_server_launch_configuration.id
    version = "$Latest"
  }

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  health_check_type         = "EC2"

  tag {
    key                 = "Name"
    value               = "MitilServerInstance"
    propagate_at_launch = true
  }
}

resource "aws_ecs_task_definition" "mitil_task_definition" {
    family            = "talon-server"
    task_role_arn      = format("arn:aws:iam::%s:role/ecsEcrTaskExecutionRole", var.AWS_ACCOUNT)
    execution_role_arn = format("arn:aws:iam::%s:role/ecsEcrTaskExecutionRole", var.AWS_ACCOUNT)

    container_definitions = templatefile("${path.module}/templates/ecs/ecs-task-definition.json", { IMAGE: var.DOCKER_IMAGE })
}

resource "aws_ecs_service" "mitil_ecs_service" {
    name = "talon-server"
    cluster = aws_ecs_cluster.mitil_server_cluster.id
    task_definition = aws_ecs_task_definition.mitil_task_definition.arn
    desired_count = 1


    force_new_deployment = true
    triggers = {
      redeployment = timestamp()
  }
}

