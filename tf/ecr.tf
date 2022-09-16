resource "aws_ecr_repository" "rko-router" {
  name = "rko-router"
}

resource "aws_ecr_lifecycle_policy" "rko-router" {
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
