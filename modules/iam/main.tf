// create IAM Policies

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssmGetParamRule" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]

    resources = ["*"]
  }
}

// IAM Role for ec2 to ecr image pull
resource "aws_iam_role" "ecsInstanceRole" {
  name = "ecsInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "ecsInstanceProfile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecsInstanceRole.name
}

resource "aws_iam_role_policy_attachment" "ecsAssumeRole" {
  for_each = toset([
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
      "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
  ])

    role = aws_iam_role.ecsInstanceRole.name
    policy_arn = each.value
}

resource "aws_iam_policy" "ecsGetParamsPolicy" {
  name = "ecsGetParamsPolicy"
  policy = "${data.aws_iam_policy_document.ssmGetParamRule.json}"
}

resource "aws_iam_role_policy_attachment" "ecsGetParameterRule" {
  role       = aws_iam_role.ecsInstanceRole.name
  policy_arn = aws_iam_policy.ecsGetParamsPolicy.arn
}

// IAM role for ecs task execution

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_instance_profile" "ecsTaskExecutionProfile" {
  name = "ecsTaskExecutionProfile"
  role = aws_iam_role.ecsTaskExecutionRole.name
}

resource "aws_iam_role_policy_attachment" "ecsExecutionRole" {
  for_each = toset([
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
      "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ])

    role = aws_iam_role.ecsTaskExecutionRole.name
    policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "ecsTaskGetParameterRule" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.ecsGetParamsPolicy.arn
}

output "ecs_instance_profile_arn" {
  value = aws_iam_instance_profile.ecsInstanceProfile.arn
}
