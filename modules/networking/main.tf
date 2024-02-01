// create certificates
variable "ENVIRONMENT" {
    type = string
}

resource "aws_acm_certificate" "mitil_in" {
  domain_name               = "mitil.in"
  subject_alternative_names = ["*.mitil.in"]
  validation_method         = "DNS"

  tags = {
    Environment = "prod"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "mitil_in" {
 name = "mitil.in"
}

resource "aws_route53_record" "mitil_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.mitil_in.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.mitil_in.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [
    each.value.record,
  ]

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "mitil_in" {
  certificate_arn         = aws_acm_certificate.mitil_in.arn
  validation_record_fqdns = [for record in aws_route53_record.mitil_acm_validation : record.fqdn]
}

resource "aws_route53_record" "mitil_app_route_alias" {
  zone_id = aws_route53_zone.mitil_in.zone_id
  name    = "api.${aws_route53_zone.mitil_in.name}"
  type    = "A"
  alias {
    name                   = aws_lb.mitil_lb.dns_name
    zone_id                = aws_lb.mitil_lb.zone_id
    evaluate_target_health = true
  }
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
    vpc_id                  = aws_vpc.mitil_vpc.id
    cidr_block              = cidrsubnet(aws_vpc.mitil_vpc.cidr_block, 8, 1)
    map_public_ip_on_launch = true
    availability_zone       = "ap-south-1b"

    tags = {
      Name = "${var.mitil_subnet1_tag}"
    }
}

resource "aws_subnet" "mitil_server_subnet2" {
    vpc_id                  = aws_vpc.mitil_vpc.id
    cidr_block              = cidrsubnet(aws_vpc.mitil_vpc.cidr_block, 8, 2)
    map_public_ip_on_launch = true
    availability_zone       = "ap-south-1a"

    tags = {
      Name = "${var.mitil_subnet2_tag}"
    }
}


resource "aws_route_table_association" "mitil_server_route" {
  route_table_id = aws_route_table.mitil_sever_rt.id
  subnet_id = aws_subnet.mitil_server_subnet.id
}

resource "aws_route_table_association" "mitil_server_route2" {
  route_table_id = aws_route_table.mitil_sever_rt.id
  subnet_id = aws_subnet.mitil_server_subnet2.id
}

resource "aws_security_group" "mitil_api_sg" {
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

resource "aws_lb" "mitil_lb" {
  name               = "mitil-server-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.mitil_api_sg.id]
  subnets         = [aws_subnet.mitil_server_subnet.id, aws_subnet.mitil_server_subnet2.id]

  enable_deletion_protection = false

  tags = {
      Environment = var.ENVIRONMENT
      Name = "MitilServerLoadBalancer"
    }
}

resource "aws_lb_listener" "mitil_lb_listener" {
    load_balancer_arn = aws_lb.mitil_lb.arn
    port = "443"
    protocol = "HTTPS"
    certificate_arn   = aws_acm_certificate.mitil_in.arn
    ssl_policy = "ELBSecurityPolicy-2016-08"

    depends_on = [ aws_acm_certificate_validation.mitil_in ]

    default_action {
      type = "fixed-response"
 
      fixed_response {
       content_type = "text/plain"
       message_body = "HEALTHY"
       status_code  = "200"
     }
    }
}

resource "aws_ecs_cluster" "mitil_server_cluster" {
  name = "mitil-server-cluster"
}

output "mitil_server_subnet_id" {
    value = aws_subnet.mitil_server_subnet.id
}

output "mitil_server_subnet2_id" {
    value = aws_subnet.mitil_server_subnet2.id
}

output "aws_mitil_vpc_id" {
    value = aws_vpc.mitil_vpc.id
}

output "aws_mitil_lb_listener_arn" {
    value = aws_lb_listener.mitil_lb_listener.arn
}

output "aws_mitil_cluster_id" {
    value = aws_ecs_cluster.mitil_server_cluster.id
}

output "mitil_api_security_group_id" {
  value = aws_security_group.mitil_api_sg.id
}
