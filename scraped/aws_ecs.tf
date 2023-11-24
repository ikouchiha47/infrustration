// Routing
variable "aws_vpc_cidr" {
  type = string
  description = "CIDR range for talon app server"
  default = "10.0.0.0/16"
}

resource "aws_vpc" "talon_vpc" {
  cidr_block = var.aws_vpc_cidr
  enable_dns_hostnames = true
  tags = {
    name = "talon_vpc"
  }
}

resource "aws_launch_template" "talon_server_lt" {
  name_prefix = "talon-server-template"
  // image_id = "ami-0d92749d46e71c34c"
  image_id = "ami-027a0367928d05f3e"
  instance_type = "t2.micro"
  key_name = "tf-key-pair"

  vpc_security_group_ids = [aws_security_group.api_security_group.id]

  iam_instance_profile {
    name = "ecsInstanceRole"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
     volume_size = 30
     volume_type = "gp2"
   }
 }

  tag_specifications {
    resource_type = "instance"
      tags = {
        Name = "ecs-instance"
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/ecs/setup.sh", { IMAGE = var.DOCKER_IMAGE, AWS_ACCOUNT = var.AWS_ACCOUNT }))
}


resource "aws_subnet" "talon_server_subnet" {
  vpc_id                  = aws_vpc.talon_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.talon_vpc.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
}

resource "aws_subnet" "talon_server_subnet2" {
  vpc_id                  = aws_vpc.talon_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.talon_vpc.cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"
}

// internet gateway to make server access the internet. (making it public)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.talon_vpc.id
  tags = {
    Name = "internet_gateway"
  }
}

// routing table to attach table to internet gateway
resource "aws_route_table" "route_table"  {
  vpc_id = aws_vpc.talon_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

// associate the subnet we want to make public to route_table attached to public IGW
resource "aws_route_table_association" "talon_server_subnet" {
  subnet_id = aws_subnet.talon_server_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "talon_server_subnet2" {
  subnet_id = aws_subnet.talon_server_subnet2.id
  route_table_id = aws_route_table.route_table.id
}

// Firewall/Securitu Group to apply on vpc
resource "aws_security_group" "api_security_group" {
  name = "TaolnAPISg"
  vpc_id = aws_vpc.talon_vpc.id

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


  ingress {
    protocol    = "tcp"
    from_port   = 9090
    to_port     = 9090
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.api_security_group.id]
  subnets            = [aws_subnet.talon_server_subnet.id, aws_subnet.talon_server_subnet2.id]

  tags = {
    Name = "ecs-alb"
  }
}


resource "aws_lb_target_group" "talon_ecs_tg" {
 name        = "TalonServerLbTarget"
 port        = 9090
 protocol    = "HTTP"
 target_type = "instance"
 vpc_id      = aws_vpc.talon_vpc.id
 health_check {
   path = "/talon/api/ping"
   healthy_threshold = 3
   interval = 30
   unhealthy_threshold = 3
   matcher = "200"
 }
}


resource "aws_autoscaling_group" "talon_ecs_asg" {
  name = "TalonApiASG"
  vpc_zone_identifier = [aws_subnet.talon_server_subnet.id, aws_subnet.talon_server_subnet2.id]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  target_group_arns = [aws_lb_target_group.talon_ecs_tg.arn]

 launch_template {
   id = aws_launch_template.talon_server_lt.id
   version = "$Latest"
 }

 tag {
   key                 = "AmazonECSManaged"
   value               = true
   propagate_at_launch = true
 }

 tag {
   key = "Name"
   value = "TalonApiASG"
   propagate_at_launch = true
 }
}
resource "aws_lb_listener" "ecs_alb_listener" {
  depends_on = [  aws_lb_target_group.talon_ecs_tg ]
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.talon_ecs_tg.arn
 }

//  default_action {
//   type = "fixed-response"
// 
//     fixed_response {
//       content_type = "text/plain"
//       message_body = "HEALTHY"
//       status_code  = "200"
//     }
//  }
}

// resource "aws_lb_listener_rule" "talon_api_rule" {
//   listener_arn =  aws_lb_listener.ecs_alb_listener.arn
//   priority = 100
// 
//   action {
//     type             = "forward"
//     target_group_arn = aws_lb_target_group.talon_ecs_tg.arn
//  }
// 
//  condition {
//    path_pattern {
//      values = ["/talon/api/*"]
//    }
//  }
// }


// Hosting service

variable "DOCKER_IMAGE" {
  type = string
}

variable "AWS_ACCOUNT" {
  type = string
}

// create cluser
// capacity provider (optional)
// ecs task definition
// ecs service to connect cluser, capacity_provider, task

resource "aws_ecs_cluster" "talon_cluster" {
 name = "talon-api-cluster"
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
  filename = "tf-key-pair"
}


// resource "aws_autoscalingplans_scaling_plan" "talon_ecs_asg_plan" {
//   name = "TalonApiASGPlan"
// 
//   application_source {
//     tag_filter {
//       key    = "Name"
//       values = ["TalonApiASG"]
//     }
//   }
// 
//   scaling_instruction {
//     max_capacity       = 1
//     min_capacity       = 0
//     resource_id        = format("autoScalingGroup/%s", aws_autoscaling_group.talon_ecs_asg.name)
//     scalable_dimension = "autoscaling:autoScalingGroup:DesiredCapacity"
//     service_namespace  = "autoscaling"
// 
//     target_tracking_configuration {
//       predefined_scaling_metric_specification {
//         predefined_scaling_metric_type = "ASGAverageCPUUtilization"
//       }
// 
//       target_value = 40
//     }
//   }
// }

resource "aws_ecs_capacity_provider" "ecs_talon_cp" {
  name = "TalonCapacityProvider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.talon_ecs_asg.arn

    managed_scaling {
     maximum_scaling_step_size = 1000
     minimum_scaling_step_size = 1
     status                    = "ENABLED"
     target_capacity           = 1
   }
 }
}


resource "aws_ecs_cluster_capacity_providers" "ecs_talon_cluster_cp" {
  cluster_name = aws_ecs_cluster.talon_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_talon_cp.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_talon_cp.name
  }
}

resource "aws_ecs_task_definition" "server_ecs_task_definition" {
 family             = "TalonDeployTask"
 network_mode       = "awsvpc"
 task_role_arn      = format("arn:aws:iam::%s:role/ecsEcrTaskExecutionRole", var.AWS_ACCOUNT)
 execution_role_arn = format("arn:aws:iam::%s:role/ecsEcrTaskExecutionRole", var.AWS_ACCOUNT)
 cpu                = 1024

 requires_compatibilities = ["EC2"]

 container_definitions = jsonencode([
   {
     name      = "talon_dockergs"
     image     = var.DOCKER_IMAGE
     cpu       = 1024
     memory    = 1024
     essential = true
     portMappings = [
       {
         containerPort = 9090
         protocol      = "tcp"
       }
     ],
     logConfiguration: {
       logDriver: "awslogs",
        options: {
          "awslogs-group": "talon-server-container",
          "awslogs-region": "ap-south-1",
          "awslogs-create-group":  "true",
          "awslogs-stream-prefix": "talon"
        }
      }
   }
 ])
}

variable "redeployment_timestamp" {
  type    = string
  default = "2023-11-23T19:30:43Z" # Set a specific timestamp
}

resource "aws_ecs_service" "talon_server_service" {
  name            = "TalonServerEcsTask"
  cluster         = aws_ecs_cluster.talon_cluster.id
  task_definition = aws_ecs_task_definition.server_ecs_task_definition.arn
  desired_count   = 1
  // launch_type     = "EC2"

  network_configuration {
    subnets         = [aws_subnet.talon_server_subnet.id, aws_subnet.talon_server_subnet2.id]
    security_groups = [aws_security_group.api_security_group.id]
  }

  force_new_deployment = true

  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_talon_cp.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.talon_ecs_tg.arn
    container_name   = "talon_dockergs"
    container_port   = 9090
 }
}
