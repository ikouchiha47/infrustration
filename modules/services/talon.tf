// iam and ssm 
data "aws_ssm_parameter" "version" {
  name = "/${var.ENVIRONMENT}/${var.PARAM_PREFIX}/version"
  with_decryption = true
}

data "aws_iam_instance_profile" "ecs_instance_profile_arn" {
  name = "ecsInstanceRole"
}

data "aws_security_group" "security_group" {
  name = "MitilAPISg"
}

resource "aws_launch_template" "mitil_server_launch_configuration" {
  name_prefix = var.APP_NAME
  image_id      = "ami-027a0367928d05f3e"
  instance_type = "t2.micro"
  key_name      = "tf-key-pair"
  vpc_security_group_ids = [data.aws_security_group.security_group.id]


  iam_instance_profile {
    // name = "ecsInstanceRole"
    arn = data.aws_iam_instance_profile.ecs_instance_profile_arn
  }

  user_data = filebase64("${path.module}/templates/ecs/ecs.sh")
}

data "aws_vpc" "vpc" {
  tags = {
      Name = "Talon VPC"
  }
}
// Talon API Server
resource "aws_lb_target_group" "mitil_lb_tg" {
    name = "MitilServerTgHttp"
    port = 9090
    protocol = "HTTP"
    vpc_id = data.aws_vpc.vpc.id

    health_check {    
      healthy_threshold   = 3    
      unhealthy_threshold = 10    
      timeout             = 5    
      interval            = 30    
      path                = "/ping"    
      port                = "9090"
      matcher             = "200-299" 
  }
}


data "aws_lb" "loadbalancer" {
  name = "mitil-server-lb"
}

data "aws_lb_listener" "https_lb" {
  load_balancer_arn = data.aws_lb.loadbalancer.arn
  port              = 443
}

resource "aws_lb_listener_rule" "mitil_server_lb" {
  listener_arn = data.aws_lb_listener.https_lb.arn
  priority = 100

  action {
      type = "forward"
      target_group_arn = aws_lb_target_group.mitil_lb_tg.arn
    }

  condition {
    path_pattern {
      values = ["/talon/api/*"]
    }
  }
}

data "aws_subnet" "subnet1" {
  filter {
      name = "tag:Name"
      values = ["${var.mitil_subnet1_tag}"]
    }
}

data "aws_subnet" "subnet2" {
  filter {
      name = "tag:Name"
      values = ["${var.mitil_subnet2_tag}"]
    }
}

resource "aws_autoscaling_group" "mitil_server_ecs_asg" {
  name                = "MitilServerAsg"
  vpc_zone_identifier = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]
  target_group_arns = [aws_lb_target_group.mitil_lb_tg.arn]

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

  tag {
   key                 = "AmazonECSManaged"
   value               = true
   propagate_at_launch = true
 }
}


// Create a auto scaling group which with a variable
// ECS_CLUSTER set to server Cluster

resource "aws_ecs_task_definition" "mitil_task_definition" {
    family            = "talon-server"
    // task_role_arn      = format("arn:aws:iam::%s:role/ecsEcrTaskExecutionRole", var.AWS_ACCOUNT)
    // execution_role_arn = format("arn:aws:iam::%s:role/ecsEcrTaskExecutionRole", var.AWS_ACCOUNT)
    // execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn

    container_definitions = templatefile("${path.module}/templates/ecs/ecs-task-definition.json", {
      IMAGE: format("%s.dkr.ecr.%s.amazonaws.com/%s", var.AWS_ACCOUNT, var.AWS_REGION, data.aws_ssm_parameter.version.value)
    })
}

data "aws_ecs_cluster" "selected" {
  cluster_name = "mitil-server-cluster"
}

resource "aws_ecs_service" "mitil_ecs_service" {
    name = "talon-server"
    cluster = aws_ecs_cluster.selected.id 
    task_definition = aws_ecs_task_definition.mitil_task_definition.arn
    desired_count = 1


    force_new_deployment = true
    triggers = {
      redeployment = plantimestamp()
  }
}
