resource "aws_iam_role" "rko-router-deploy" {
  name               = "GhaRkoRouterDeploy"
  description        = "rko-router tf/iam.tf"
  assume_role_policy = data.aws_iam_policy_document.rko-router-deploy-trust.json
}

data "aws_iam_policy_document" "rko-router-deploy-trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github-actions.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ruby-no-kai/rko-router:environment:apprunner-prod",
        "repo:ruby-no-kai/rko-router:ref:refs/heads/master",
        "repo:ruby-no-kai/rko-router:ref:refs/heads/test",
      ]
    }
  }
}

resource "aws_iam_role_policy" "rko-router-deploy-ecr" {
  role   = aws_iam_role.rko-router-deploy.name
  policy = data.aws_iam_policy_document.rko-router-deploy-ecr.json
}

data "aws_iam_policy_document" "rko-router-deploy-ecr" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecr:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",

      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      aws_ecr_repository.rko-router.arn,
    ]
  }

}

resource "aws_iam_role_policy" "rko-router-deploy-apprunner" {
  role   = aws_iam_role.rko-router-deploy.name
  policy = data.aws_iam_policy_document.rko-router-deploy-apprunner.json
}

data "aws_iam_policy_document" "rko-router-deploy-apprunner" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [aws_iam_role.rko-router-access.arn]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ruby-no-kai/rko-router:environment:apprunner-prod",
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "apprunner:DescribeService",
      "apprunner:UpdateService",
    ]
    resources = [
      aws_apprunner_service.rko-router.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ruby-no-kai/rko-router:environment:apprunner-prod",
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "apprunner:ListServices",
    ]
    resources = ["*"]
  }
}
