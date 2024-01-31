module "iam_policies" {
  source = "../iam"
}

module "networking" {
    source = "../networking"
    ENVIRONMENT = var.ENVIRONMENT
}

data "aws_ssm_parameter" "version" {
  name = "${var.ENVIRONMENT}/${var.PARAM_PREFIX}/version"
  with_decryption = true
}

resource "aws_launch_template" "mitil_server_launch_configuration" {
  name_prefix = var.APP_NAME
  image_id      = "ami-027a0367928d05f3e"
  instance_type = "t2.micro"
  key_name      = "tf-key-pair"
  vpc_security_group_ids = [module.networking.mitil_api_security_group_id]


  iam_instance_profile {
    // name = "ecsInstanceRole"
    arn = module.iam_policies.ecs_instance_profile_arn
  }

  user_data = filebase64("${path.module}/templates/ecs/ecs.sh")
}

// Talon API Server
resource "aws_lb_target_group" "mitil_lb_tg" {
    name = "MitilServerTgHttp"
    port = 9090
    protocol = "HTTP"
    vpc_id = module.networking.aws_mitil_vpc_id

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

resource "aws_lb_listener_rule" "mitil_server_lb" {
  listener_arn = module.networking.aws_mitil_lb_listener_arn
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

resource "aws_autoscaling_group" "mitil_server_ecs_asg" {
  name                = "MitilServerAsg"
  vpc_zone_identifier = [module.networking.mitil_server_subnet_id, module.networking.mitil_server_subnet2_id]
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
      IMAGE: format("%s.dkr.ecr.%s.amazonaws.com/%s", var.AWS_ACCOUNT, var.AWS_REGION, aws_ssm_parameter.version.value)
    })
}

resource "aws_ecs_service" "mitil_ecs_service" {
    name = "talon-server"
    cluster = module.networking.aws_mitil_cluster_id
    task_definition = aws_ecs_task_definition.mitil_task_definition.arn
    desired_count = 1


    force_new_deployment = true
    triggers = {
      redeployment = plantimestamp()
  }
}
