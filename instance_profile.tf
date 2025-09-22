
data "aws_iam_policy_document" "ec2_inst_profile_role_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = [
        "ec2.amazonaws.com"
      ]
      type = "Service"
    }
    effect = "Allow"
  }
}

resource "aws_iam_instance_profile" "ecs_ec2_instance_profile" {
  name = "${local.proyect_name}-instance-profile"
  role = aws_iam_role.ec2_inst_profile_role.name
}


resource "aws_iam_role" "ec2_inst_profile_role" {
  name               = "${local.proyect_name}-instance-profile"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_inst_profile_role_assume_role_policy.json
}

data "aws_iam_policy_document" "amazon_ec2_container_service_policy" {
  statement {
    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "iam:PassRole",
      "iam:GetRole",
      "ssm:PutParameter",
      "kms:Decrypt",
      "kms:ListAliases",
      "ssm:GetParameter",
      "ec2:DescribeInstances",
      "ssm:GetParameters",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
      "ec2:DescribeTags",
      "iam:ListUsers",
      "iam:GetGroup",
      "kms:decrypt",
      "iam:GetRole",
      "iam:PassRole",
      "iam:ListInstanceProfiles",
      "iam:ListSSHPublicKeys",
      "iam:GetSSHPublicKey",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:HeadBucket",
      "ec2:DescribeRegions",
      "tag:GetResources",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "amazon_ec2_container_service" {
  name        = "${local.proyect_name}_amazon_ec2_container_service"
  path        = "/"
  description = "Policies"
  policy      = data.aws_iam_policy_document.amazon_ec2_container_service_policy.json
}


resource "aws_iam_role_policy_attachment" "amazon_ec2_container_serv" {
  role       = aws_iam_role.ec2_inst_profile_role.name
  policy_arn = aws_iam_policy.amazon_ec2_container_service.arn

}
