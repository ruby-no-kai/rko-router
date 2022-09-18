resource "aws_apprunner_service" "rko-router" {
  service_name = "rko-router"

  source_configuration {
    image_repository {
      image_configuration {
        port = "8080"
      }
      image_identifier      = "${aws_ecr_repository.rko-router.repository_url}:latest"
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.rko-router-access.arn
    }
    auto_deployments_enabled = false
  }

  # minimum
  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 5
  }

  tags = {
    Name    = "rko-router"
    Project = "rko-router"
  }

  lifecycle {
    ignore_changes = [source_configuration[0].image_repository[0].image_identifier]
  }
}

resource "aws_iam_role" "rko-router-access" {
  name               = "AppraRkoRouter"
  description        = "rko-router tf/iam.tf"
  assume_role_policy = data.aws_iam_policy_document.rko-router-access-trust.json
}

data "aws_iam_policy_document" "rko-router-access-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "build.apprunner.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "rko-router-access" {
  role   = aws_iam_role.rko-router-access.name
  policy = data.aws_iam_policy_document.rko-router-access.json
}

data "aws_iam_policy_document" "rko-router-access" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
    ]
    resources = [
      aws_ecr_repository.rko-router.arn,
    ]
  }
}
