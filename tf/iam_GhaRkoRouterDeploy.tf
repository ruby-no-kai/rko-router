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
        "repo:ruby-no-kai/rko-router:environment:lambda-prod",
        "repo:ruby-no-kai/rko-router:ref:refs/heads/master",
        "repo:ruby-no-kai/rko-router:ref:refs/heads/test",
        "repo:ruby-no-kai/rko-router:pull_request", # non-fork PRs: public.ecr.aws login only (see below)
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
      "ecr-public:GetAuthorizationToken", # authenticated pulls from public.ecr.aws (base images in Dockerfile)
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

    # pull_request runs only need the public.ecr.aws login above
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ruby-no-kai/rko-router:environment:lambda-prod",
        "repo:ruby-no-kai/rko-router:ref:refs/heads/master",
        "repo:ruby-no-kai/rko-router:ref:refs/heads/test",
      ]
    }
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
      "lambda:UpdateFunctionCode",
    ]
    resources = [
      aws_lambda_function.rko-router.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ruby-no-kai/rko-router:environment:lambda-prod",
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = [
      aws_ecr_repository.rko-router.arn,
    ]
  }

}
