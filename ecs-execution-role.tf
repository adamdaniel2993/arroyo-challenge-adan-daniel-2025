data "aws_iam_policy_document" "ecs_exec_role_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "ssm.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "ecs_exec_role" {
  name               = "${local.proyect_name}-ecs-exec"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_exec_role_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_execution_role_permissions_policy" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "logs:PutLogEvents",
      "ssm:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "ecr:GetRegistryPolicy",
      "ecr:DescribeImageScanFindings",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeRegistry",
      "ecr:DescribePullThroughCacheRules",
      "ecr:DescribeImageReplicationStatus",
      "ecr:GetAuthorizationToken",
      "ecr:ListTagsForResource",
      "ecr:ListImages",
      "ecr:BatchGetRepositoryScanningConfiguration",
      "ecr:GetRegistryScanningConfiguration",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetRepositoryPolicy",
      "ecr:GetLifecyclePolicy"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}


resource "aws_iam_policy" "ecs_execution_role_permissions" {
  name        = "ecs_execution_role_permissions"
  path        = "/"
  description = "A policy with necessary permissions to create a complete ecs cluster"

  policy = data.aws_iam_policy_document.ecs_execution_role_permissions_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = aws_iam_policy.ecs_execution_role_permissions.arn

}
