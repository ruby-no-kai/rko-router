resource "aws_apprunner_service" "rko-router-apne1" {
  provider     = aws.apne1
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

resource "aws_ecr_repository" "rko-router-apne1" {
  provider = aws.apne1
  name     = "rko-router"
}

resource "aws_ecr_lifecycle_policy" "rko-router-apne1" {
  provider   = aws.apne1
  repository = aws_ecr_repository.rko-router.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 10
        description  = "expire old images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
